import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mediaInput", "poll"]

  attachMedia() {
    this.mediaInputTarget.click()
  }

  attachVideo() {
    this.attachMedia()
  }

  togglePoll() {
    this.pollTarget.classList.toggle("d-none")
  }
}
