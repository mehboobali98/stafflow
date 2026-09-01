import { Controller } from "@hotwired/stimulus"

// Fills in the unread count on the bell in the dashboard navbar.
//
// The URL is a value rather than the "/notifications/count" the bundle had
// hardcoded, so it comes from the route helper and moving the route cannot
// leave this pointing at a 404 that only shows up as a badge that never fills.
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.load()
  }

  async load() {
    try {
      const response = await fetch(this.urlValue, {
        headers: { Accept: "application/json" }
      })
      if (!response.ok) return

      this.element.textContent = await response.json()
    } catch {
      // A count that will not load leaves the badge as the template rendered
      // it. It is an ornament on a link to the page that has the real list.
    }
  }
}
