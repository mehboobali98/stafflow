import { Controller } from "@hotwired/stimulus"

// The collapse toggle on the dashboard sidebar. The panel and the content it
// sits beside come from two different templates - the sidebar partial and the
// application layout - so the controller goes on the element containing both
// and each half names itself as a target.
//
// The original did not toggle a class on the content, it swapped one: it
// removed `home-content` and added `sidebar-toggle`, so after a click the class
// the stylesheet keyed off had left the document, and the two rules behind them
// duplicated four of their six declarations to say the same thing twice. One
// `expanded` modifier on each half replaces both, which is also why the panel's
// state class is no longer spelled differently from the content's.
export default class extends Controller {
  static targets = ["panel", "content"]

  toggle() {
    this.panelTarget.classList.toggle("expanded")
    this.contentTarget.classList.toggle("expanded")
  }
}
