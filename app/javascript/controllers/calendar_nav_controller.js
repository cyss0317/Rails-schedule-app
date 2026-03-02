import { Controller } from "@hotwired/stimulus";

// data-controller="calendar-nav"
// Handles: left/right arrow key navigation to previous/next week or month.
// The controller lives on .calendar-heading so it's shared by both weekly
// and monthly views.  Prev/next links must carry data-nav="prev"|"next".
export default class extends Controller {
  connect() {
    this._handleKey = this._handleKey.bind(this);
    document.addEventListener("keydown", this._handleKey);
  }

  disconnect() {
    document.removeEventListener("keydown", this._handleKey);
  }

  _handleKey(e) {
    // Ignore while the user is typing in a form control
    const tag = document.activeElement?.tagName;
    if (["INPUT", "TEXTAREA", "SELECT"].includes(tag)) return;
    if (document.activeElement?.isContentEditable) return;

    let href;
    if (e.key === "ArrowLeft") {
      href = this.element.querySelector("[data-nav='prev']")?.href;
    } else if (e.key === "ArrowRight") {
      href = this.element.querySelector("[data-nav='next']")?.href;
    }

    if (href) {
      e.preventDefault();
      Turbo.visit(href);
    }
  }
}
