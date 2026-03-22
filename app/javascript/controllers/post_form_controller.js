import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mediaInput",
    "typeSelect",
    "bodyInput",
    "bodyLabel",
    "helperText",
    "quoteField",
    "quoteInput",
    "progressField",
    "progressInput",
    "ratingField",
  ]

  connect() {
    this.syncForm()
  }

  attachMedia() {
    this.mediaInputTarget.click()
  }

  attachVideo() {
    this.attachMedia()
  }
  syncForm() {
    if (!this.hasTypeSelectTarget) {
      return
    }

    const type = this.typeSelectTarget.value
    const config = {
      started_reading: {
        label: "Opening note",
        placeholder: "What pulled you into this book?",
        helper: "Share the mood, the setup, or why you picked it up.",
        quote: false,
        progress: false,
        rating: false,
      },
      finished_reading: {
        label: "Closing thought",
        placeholder: "How did the ending leave you feeling?",
        helper: "A final impression works well here. Rating is optional.",
        quote: false,
        progress: false,
        rating: true,
      },
      progress_update: {
        label: "Reading note",
        placeholder: "What just happened, without spoiling too much?",
        helper: "Progress updates are perfect for a scene reaction or midpoint check-in.",
        quote: false,
        progress: true,
        rating: false,
      },
      favorite_quote: {
        label: "Why it stayed with you",
        placeholder: "What about this line made you stop?",
        helper: "Add the quote and a quick note about why it mattered.",
        quote: true,
        progress: false,
        rating: false,
      },
      quick_thought: {
        label: "Quick thought",
        placeholder: "Share a short review, a reaction, or a recommendation.",
        helper: "A line or two is enough. Rating is optional.",
        quote: false,
        progress: false,
        rating: true,
      },
    }[type] || {
      label: "Thought",
      placeholder: "Share a reading update.",
      helper: "Keep it short and readable.",
      quote: false,
      progress: false,
      rating: false,
    }

    this.bodyLabelTarget.textContent = config.label
    this.bodyInputTarget.placeholder = config.placeholder
    this.helperTextTarget.textContent = config.helper
    this.quoteFieldTarget.classList.toggle("d-none", !config.quote)
    this.progressFieldTarget.classList.toggle("d-none", !config.progress)
    this.ratingFieldTarget.classList.toggle("d-none", !config.rating)
    this.quoteInputTarget.required = config.quote
    this.progressInputTarget.required = type === "progress_update"
  }
}
