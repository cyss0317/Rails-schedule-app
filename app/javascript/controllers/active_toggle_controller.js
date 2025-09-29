// app/javascript/controllers/role_toggle_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { url: String };
  static targets = ["checkbox", "label"];

  toggle() {
    const nextOn = this.checkboxTarget.checked;
    // ... apply visuals ...
    fetch(this.urlValue, {
      method: "PATCH",
      headers: { Accept: "text/vnd.turbo-stream.html",
                 "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content },
      credentials: "same-origin",
    }).catch(() => {
      // revert on error
      this.checkboxTarget.checked = !nextOn;
      // ... revert visuals ...
    });
  }
}