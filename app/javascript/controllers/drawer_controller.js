// drawer_controller.js
import { Controller } from "@hotwired/stimulus";


export default class extends Controller {
  static targets = ["root", "backdrop", "panel"];

  connect() {
    this.isOpen = false;
    this._esc = (e) => {
      if (e.key === "Escape") this.close();
    };
  }

  open(event) {
    this.isOpen = true;
    this.rootTarget.classList.remove("hidden");

    // animate in
    requestAnimationFrame(() => {
      this.backdropTarget.classList.remove("opacity-0");
      this.panelTarget.classList.remove("translate-x-full");
      document.addEventListener("keydown", this._esc);
      // move focus inside for a11y
      this.panelTarget.focus();
      this._setAria(true, event?.currentTarget);
    });
  }

  close() {
    if (!this.isOpen) return;
    this.isOpen = false;

    // animate out
    this.backdropTarget.classList.add("opacity-0");
    this.panelTarget.classList.add("translate-x-full");

    // after transition, hide root
    const done = () => {
      this.rootTarget.classList.add("hidden");
      this.panelTarget.removeEventListener("transitionend", done);
    };
    this.panelTarget.addEventListener("transitionend", done);

    document.removeEventListener("keydown", this._esc);
    this._setAria(false);
  }

  _setAria(expanded, btn) {
    const trigger =
      btn || document.querySelector('[aria-controls="hamburger-drawer"]');
    if (trigger)
      trigger.setAttribute("aria-expanded", expanded ? "true" : "false");
  }
}
