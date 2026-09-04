import { Controller } from "@hotwired/stimulus"

/**
 * Refills a select from a JSON endpoint whenever the control it depends on
 * changes.
 *
 * `urlValue` is a route carrying the literal token `VALUE` in place of the id
 * of whatever was chosen, so the view can build it from a path helper whether
 * that id belongs in the path or in the query string.
 */
export default class extends Controller {
  static targets = ["select"]

  static values = {
    url: String,
    labelAttribute: { type: String, default: "name" }
  }

  async load(event) {
    const id = event.detail?.value ?? event.target.value
    if (!id) return

    const response = await fetch(this.urlValue.replace("VALUE", encodeURIComponent(id)), {
      headers: { Accept: "application/json" }
    })
    if (!response.ok) return

    this.replace(await response.json())
  }

  replace(records) {
    this.selectTarget.innerHTML = ""

    records.forEach((record) => {
      const option = document.createElement("option")
      option.value = record.id
      option.textContent = record[this.labelAttributeValue]
      this.selectTarget.appendChild(option)
    })
  }
}
