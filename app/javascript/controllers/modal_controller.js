import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  connect() {
    this.observer = new MutationObserver(() => this.sync())
    this.observer.observe(this.contentTarget, { childList: true })
    this.sync()
  }

  disconnect() {
    this.observer.disconnect()
    this.hide()
  }

  sync() {
    if (this.contentTarget.children.length > 0) {
      this.show()
    } else {
      this.hide()
    }
  }

  close() {
    this.contentTarget.innerHTML = ""
    this.contentTarget.removeAttribute("src")
    this.hide()
  }

  show() {
    this.element.classList.add("show")
    this.element.style.display = "block"
    this.element.removeAttribute("aria-hidden")
    document.body.classList.add("modal-open")

    if (!this.backdrop) {
      this.backdrop = document.createElement("div")
      this.backdrop.className = "modal-backdrop fade show"
      document.body.appendChild(this.backdrop)
    }
  }

  hide() {
    this.element.classList.remove("show")
    this.element.style.display = "none"
    this.element.setAttribute("aria-hidden", "true")
    document.body.classList.remove("modal-open")

    if (this.backdrop) {
      this.backdrop.remove()
      this.backdrop = null
    }
  }
}
