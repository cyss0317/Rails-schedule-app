import { Controller } from "@hotwired/stimulus";

// data-controller="modal"
export default class extends Controller {
  static targets = ["root", "backdrop", "panel"];
  static values = { open: Boolean };

  connect() {
    // initialize visibility based on openValue
    this.toggle(this.openValue);
    // close on ESC
    this._onKeydown = (e) => {
      if (e.key === "Escape") this.close();
    };
    document.addEventListener("keydown", this._onKeydown);
  }

  disconnect() {
    document.removeEventListener("keydown", this._onKeydown);
  }

  open() {
    this.toggle(true);
  }
  close() {
    this.toggle(false);
  }

  // click on backdrop to close (ignore clicks inside panel)
  backdrop(e) {
    if (e.target === this.backdropTarget) this.close();
  }

  toggle(show) {
    this.openValue = !!show;
    // Tailwind-friendly: rely on `hidden` utility
    this.rootTarget.classList.toggle("hidden", !this.openValue);
  }
}
