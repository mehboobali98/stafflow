import { Controller } from "@hotwired/stimulus"

/**
 * A text input that searches a JSON endpoint and offers what comes back as an
 * ARIA listbox, writing the chosen record's id into a hidden field.
 *
 * Dispatches `combobox:select` with `{ value, label }` when a record is picked.
 */
export default class extends Controller {
  static targets = ["input", "listbox", "field", "status"]

  static values = {
    url: String,
    labelAttribute: { type: String, default: "name" },
    minLength: { type: Number, default: 1 },
    debounce: { type: Number, default: 150 },
    emptyMessage: String,
    countMessage: String
  }

  connect() {
    this.records = []
    this.activeIndex = -1
    this.close()
  }

  disconnect() {
    this.cancel()
    this.close()
    this.listboxTarget.innerHTML = ""
  }

  search() {
    this.cancel()
    this.fieldTarget.value = ""

    const query = this.inputTarget.value.trim()
    if (query.length < this.minLengthValue) {
      this.reset()
      return
    }

    this.timer = setTimeout(() => this.load(query), this.debounceValue)
  }

  async load(query) {
    this.pending = new AbortController()

    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("query", query)

    try {
      const response = await fetch(url, {
        headers: { Accept: "application/json" },
        signal: this.pending.signal
      })
      if (!response.ok) return

      this.render(await response.json())
      this.open()
    } catch {
      // An aborted or failed lookup leaves the list showing the last answer
      // that did arrive, which is what the input still describes.
    }
  }

  navigate(event) {
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        if (this.expanded) this.activate(this.activeIndex + 1)
        else this.open()
        break
      case "ArrowUp":
        event.preventDefault()
        if (this.expanded) this.activate(this.activeIndex - 1)
        break
      case "Home":
        if (!this.expanded) break
        event.preventDefault()
        this.activate(0)
        break
      case "End":
        if (!this.expanded) break
        event.preventDefault()
        this.activate(this.records.length - 1)
        break
      case "Enter":
        if (!this.expanded || this.activeIndex < 0) break
        event.preventDefault()
        this.choose(this.optionAt(this.activeIndex))
        break
      case "Escape":
        this.close()
        break
      case "Tab":
        this.close()
        break
    }
  }

  retainFocus(event) {
    event.preventDefault()
  }

  pick(event) {
    const option = event.target.closest("[role=option]")
    if (option) this.choose(option)
  }

  dismiss(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  choose(option) {
    this.fieldTarget.value = option.dataset.value
    this.inputTarget.value = option.textContent.trim()
    this.close()
    this.dispatch("select", {
      detail: { value: option.dataset.value, label: this.inputTarget.value }
    })
  }

  render(records) {
    this.records = records
    this.activeIndex = -1
    this.listboxTarget.innerHTML = ""

    records.forEach((record, index) => {
      const option = document.createElement("li")
      option.id = `${this.listboxTarget.id}-option-${index}`
      option.className = "combobox__option"
      option.dataset.value = record.id
      option.textContent = record[this.labelAttributeValue]
      option.setAttribute("role", "option")
      option.setAttribute("aria-selected", "false")
      this.listboxTarget.appendChild(option)
    })

    this.announce(records.length)
    this.inputTarget.removeAttribute("aria-activedescendant")
  }

  activate(index) {
    if (this.records.length === 0) return

    const last = this.records.length - 1
    if (index < 0) this.activeIndex = last
    else if (index > last) this.activeIndex = 0
    else this.activeIndex = index

    this.optionElements.forEach((option, position) => {
      option.setAttribute("aria-selected", String(position === this.activeIndex))
      option.classList.toggle("is-active", position === this.activeIndex)
    })

    const active = this.optionAt(this.activeIndex)
    this.inputTarget.setAttribute("aria-activedescendant", active.id)
    active.scrollIntoView({ block: "nearest" })
  }

  open() {
    if (this.records.length === 0) {
      this.close()
      return
    }

    this.listboxTarget.hidden = false
    this.inputTarget.setAttribute("aria-expanded", "true")
  }

  reset() {
    this.records = []
    this.listboxTarget.innerHTML = ""
    this.close()
    if (this.hasStatusTarget) this.statusTarget.textContent = ""
  }

  close() {
    this.listboxTarget.hidden = true
    this.activeIndex = -1
    this.inputTarget.setAttribute("aria-expanded", "false")
    this.inputTarget.removeAttribute("aria-activedescendant")
    this.optionElements.forEach((option) => {
      option.setAttribute("aria-selected", "false")
      option.classList.remove("is-active")
    })
  }

  cancel() {
    clearTimeout(this.timer)
    if (this.pending) this.pending.abort()
  }

  announce(count) {
    if (!this.hasStatusTarget) return

    this.statusTarget.textContent =
      count === 0 ? this.emptyMessageValue : this.countMessageValue.replace("COUNT", count)
  }

  optionAt(index) {
    return this.optionElements[index]
  }

  get optionElements() {
    return Array.from(this.listboxTarget.querySelectorAll("[role=option]"))
  }

  get expanded() {
    return this.inputTarget.getAttribute("aria-expanded") === "true"
  }
}
