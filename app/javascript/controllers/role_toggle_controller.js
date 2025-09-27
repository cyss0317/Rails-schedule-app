// app/javascript/controllers/role_toggle_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { url: String };

  toggle(e) {
    // Optimistic UI: we flip the knob right away; Turbo will re-render the row.
    const checked = e.currentTarget.checked;

    debugger
    // Send PATCH to toggle role; no body needed—server toggles.
    fetch(this.urlValue, {
      method: "PATCH",
      headers: { Accept: "text/vnd.turbo-stream.html" },
      credentials: "same-origin",
    }).catch(() => {
      // On error, revert checkbox
      e.currentTarget.checked = !checked;
    });
  }
}
