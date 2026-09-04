import { Controller } from "@hotwired/stimulus"

// Stops the event form submitting with a year the column cannot hold. The
// server checks this too, in Event#validate_event_year; this is the copy that
// answers without a round trip.
//
// Narrower than the code it replaces, which also tested the value against a
// yyyy-mm-dd regex and for a year that parses at all. The field is
// <input type="date"> and required, so the browser will not hand over a value
// that is empty or in another shape - those two branches could not be reached.
// An over-long year can be: Chrome's date input accepts years past 9999.
//
// The message comes from the template rather than the bundle, because the rest
// of this application's copy is in en.yml and a string in here would be the
// only English the translators cannot see.
export default class extends Controller {
  static values = { message: String }

  validate(event) {
    const year = new Date(this.element.querySelector("input[type=date]").value).getFullYear()

    if (String(year).length > 4) {
      event.preventDefault()
      window.alert(this.messageValue)
    }
  }
}
