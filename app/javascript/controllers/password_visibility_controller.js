import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "toggle"]

  toggle() {
    const input = this.inputTarget
    input.type = input.type === "password" ? "text" : "password"
    if (this.hasToggleTarget) {
      this.toggleTarget.classList.toggle("bi-eye")
      this.toggleTarget.classList.toggle("bi-eye-slash")
    }
  }
}
