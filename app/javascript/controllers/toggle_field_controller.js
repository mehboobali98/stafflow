import { Controller } from "@hotwired/stimulus"

// A checkbox that enables the field beside it, and disables it again when
// unticked. Two bundles did this: user_leaves.js enabled a leave count when a
// leave was ticked, users_benefit_creation.js enabled an amount when a benefit
// was. They found their partner differently - one held a CSS selector in a data
// attribute, the other an element id - and neither could say so from the markup.
// A target says it once.
export default class extends Controller {
  static targets = ["field"]

  // The field is rendered disabled, so an unticked row is right before this
  // runs. Syncing on connect is for the way back: Turbo restores a cached
  // page with the boxes as they were left, and the fields have to agree.
  connect() {
    this.toggle()
  }

  toggle() {
    const on = this.element.querySelector("input[type=checkbox]").checked
    this.fieldTargets.forEach((field) => {
      field.disabled = !on
    })
  }
}
