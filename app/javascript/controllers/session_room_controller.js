import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["avatarStack", "countdown", "readerCount", "readerList"]
  static values = {
    active: Boolean,
    completeUrl: String,
    defaultAvatarUrl: String,
    endsAt: String,
    heartbeatUrl: String,
    presenceUrl: String,
    serverNow: String
  }

  connect() {
    if (!this.activeValue) return

    this.completing = false
    this.serverOffsetMs = this.calculateServerOffset(this.serverNowValue)
    this.visibilityHandler = () => {
      if (document.visibilityState === "visible") this.refreshPresence()
    }

    document.addEventListener("visibilitychange", this.visibilityHandler)
    this.tick()
    this.countdownTimer = window.setInterval(() => this.tick(), 1000)
    this.presenceTimer = window.setInterval(() => this.refreshPresence(), 5000)
    this.refreshPresence()
  }

  disconnect() {
    window.clearInterval(this.countdownTimer)
    window.clearInterval(this.presenceTimer)
    document.removeEventListener("visibilitychange", this.visibilityHandler)
  }

  tick() {
    const remainingSeconds = Math.max(Math.ceil((new Date(this.endsAtValue).getTime() - this.nowMs()) / 1000), 0)
    this.countdownTarget.textContent = this.formatDuration(remainingSeconds)

    if (remainingSeconds === 0) {
      this.completeSession()
    }
  }

  async refreshPresence() {
    if (this.completing) return

    try {
      const response = await fetch(this.heartbeatUrlValue, {
        method: "POST",
        headers: this.headers()
      })

      if (!response.ok) throw new Error("Presence update failed")

      const snapshot = await response.json()
      this.renderSnapshot(snapshot)
    } catch (_error) {
      const fallbackResponse = await fetch(this.presenceUrlValue, { headers: this.headers() })
      if (!fallbackResponse.ok) return

      const snapshot = await fallbackResponse.json()
      this.renderSnapshot(snapshot)
    }
  }

  async completeSession() {
    if (this.completing) return
    this.completing = true

    const response = await fetch(this.completeUrlValue, {
      method: "POST",
      headers: this.headers()
    })

    if (!response.ok) {
      this.completing = false
      return
    }

    const payload = await response.json()
    window.location.href = payload.redirect_url
  }

  renderSnapshot(snapshot) {
    if (snapshot.status !== "ACTIVE") {
      window.location.reload()
      return
    }

    this.endsAtValue = snapshot.ends_at || this.endsAtValue
    this.serverOffsetMs = this.calculateServerOffset(snapshot.server_now)
    this.readerCountTarget.textContent = `${snapshot.active_reader_count} ${snapshot.active_reader_count === 1 ? "reader" : "readers"}`
    this.renderAvatarStack(snapshot)
    this.renderReaderList(snapshot)
  }

  formatDuration(totalSeconds) {
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60
    return `${minutes.toString().padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`
  }

  renderAvatarStack(snapshot) {
    if (!this.hasAvatarStackTarget) return

    this.avatarStackTarget.innerHTML = ""

    snapshot.readers.forEach((reader) => {
      const image = document.createElement("img")
      image.className = "session-room__presence-avatar"
      image.src = reader.avatar || this.defaultAvatarUrlValue
      image.alt = reader.name

      this.avatarStackTarget.appendChild(image)
    })

    const overflowCount = snapshot.active_reader_count - snapshot.readers.length
    if (overflowCount > 0) {
      const badge = document.createElement("span")
      badge.className = "session-room__presence-overflow"
      badge.textContent = `+${overflowCount}`
      this.avatarStackTarget.appendChild(badge)
    }
  }

  renderReaderList(snapshot) {
    this.readerListTarget.innerHTML = ""

    snapshot.readers.forEach((reader) => {
      const pill = document.createElement("span")
      pill.className = "session-room__reader-pill"

      const name = document.createElement("strong")
      name.textContent = reader.name

      const meta = document.createElement("small")
      meta.textContent = this.readerMeta(reader)

      pill.appendChild(name)
      pill.appendChild(meta)
      this.readerListTarget.appendChild(pill)
    })
  }

  readerMeta(reader) {
    if (reader.host && reader.current_user) return "You, hosting"
    if (reader.host) return "Host"
    if (reader.current_user) return "You"
    return "Reading now"
  }

  calculateServerOffset(serverNow) {
    if (!serverNow) return 0

    const parsed = new Date(serverNow).getTime()
    if (Number.isNaN(parsed)) return 0

    return parsed - Date.now()
  }

  nowMs() {
    return Date.now() + this.serverOffsetMs
  }

  headers() {
    return {
      "Accept": "application/json",
      "X-CSRF-Token": this.csrfToken()
    }
  }

  csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content || ""
  }
}
