import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.element.style.cursor = 'pointer'
  }

  navigate() {
    Turbo.visit(this.urlValue)
  }

  selectDay(e) {
    e.stopPropagation();
    const td = e.currentTarget;
    window.startDate = td.dataset.date
  }
}