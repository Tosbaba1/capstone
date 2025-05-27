import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list"]

  search() {
    const query = this.inputTarget.value.trim()
    if (query === "") {
      this.listTarget.innerHTML = ""
      return
    }

    fetch(`/books/suggest?q=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(data => {
        this.listTarget.innerHTML = data
          .map(book => `<option value="${book.title}"></option>`)
          .join("")
      })
  }
}
