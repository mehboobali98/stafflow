import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "toggle", "submit"]

  itemTargetConnected() {
    this.refresh()
  }

  itemTargetDisconnected() {
    this.refresh()
  }

  toggleAll() {
    this.itemTargets.forEach((item) => {
      item.checked = this.toggleTarget.checked
    })
    this.refresh()
  }

  refresh() {
    const checked = this.itemTargets.filter((item) => item.checked)

    if (this.hasToggleTarget) {
      this.toggleTarget.checked = checked.length > 0 && checked.length === this.itemTargets.length
    }

    this.submitTargets.forEach((button) => {
      button.disabled = checked.length === 0
    })
  }
}
