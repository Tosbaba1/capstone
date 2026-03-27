import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["countdown", "readerCount", "readerList"]
  static values = {
    active: Boolean,
    completeUrl: String,
    defaultAvatarUrl: String,
    endsAt: String,
    heartbeatUrl: String,
    presenceUrl: String
  }

  connect() {
    if (!this.activeValue) return

    this.completing = false
    this.tick()
    this.countdownTimer = window.setInterval(() => this.tick(), 1000)
    this.presenceTimer = window.setInterval(() => this.refreshPresence(), 5000)
    this.refreshPresence()
  }

  disconnect() {
    window.clearInterval(this.countdownTimer)
    window.clearInterval(this.presenceTimer)
  }

  tick() {
    const remainingSeconds = Math.max(Math.floor((new Date(this.endsAtValue) - new Date()) / 1000), 0)
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

    this.readerCountTarget.textContent = `${snapshot.active_reader_count} ${snapshot.active_reader_count === 1 ? "reader" : "readers"}`
    this.readerListTarget.innerHTML = ""

    snapshot.readers.forEach((reader) => {
      const card = document.createElement("article")
      card.className = "session-room__reader"

      const image = document.createElement("img")
      image.className = "session-room__reader-avatar"
      image.src = reader.avatar || this.defaultAvatarUrlValue
      image.alt = reader.name

      const textWrapper = document.createElement("div")
      const name = document.createElement("strong")
      name.textContent = reader.name

      const meta = document.createElement("p")
      meta.className = "mb-0"
      meta.textContent = reader.host ? "Host" : (reader.current_user ? "You" : "Reading now")

      textWrapper.appendChild(name)
      textWrapper.appendChild(meta)

      card.appendChild(image)
      card.appendChild(textWrapper)

      this.readerListTarget.appendChild(card)
    })
  }

  formatDuration(totalSeconds) {
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60
    return `${minutes.toString().padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`
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
