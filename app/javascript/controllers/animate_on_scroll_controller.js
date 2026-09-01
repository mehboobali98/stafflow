import { Controller } from "@hotwired/stimulus"
import AOS from "aos"

// AOS reveals the landing page sections as they scroll into view. It was its
// own bundle, loaded by that one page; it is a controller now so that the page
// declares what it wants rather than the template remembering to load a script.
//
// `once` means an element that has been revealed stays revealed. That matters
// more under Turbo than it did before: Turbo restores a cached snapshot on a
// back navigation, and the elements in it are already revealed - without it
// they would be waiting at opacity 0 for a scroll that has already happened.
export default class extends Controller {
  connect() {
    AOS.init({ duration: 1500, easing: "ease-in-out", once: true })
  }
}
