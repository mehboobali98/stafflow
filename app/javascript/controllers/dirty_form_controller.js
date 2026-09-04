import { Controller } from "@hotwired/stimulus"

// Keeps a form's submit button disabled until something in the form changes,
// so "save" is only offered when there is something to save. The settings form
// is the one page using it.
export default class extends Controller {
  static targets = ["submit"]

  // Nothing on connect: the button is rendered disabled, so a browser that
  // never runs this still gets the state the server meant.
  enable() {
    this.submitTarget.disabled = false
  }
}
