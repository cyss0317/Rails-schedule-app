import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { text: String };

  copy(event) {
    const text = this.textValue || this.element.dataset.clipboardText;

    navigator.clipboard.writeText(text).then(() => {
      // optional feedback
      this.element.textContent = "Copied!";
      setTimeout(() => {
        this.element.textContent = "Copy Employee Sign Up URL";
      }, 1500);
    });
  }
}
