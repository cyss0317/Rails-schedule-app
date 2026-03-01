import { Controller } from "@hotwired/stimulus";
import { layoutDayEvents } from "../utils/layout_day_events";

// day-layout controller
//
// Reads event targets, runs the interval-column layout algorithm, and applies
// style.left / style.width.  Vertical layout (top / height) is untouched.
//
// Expected DOM shape:
//
//   <div data-controller="day-layout"
//        data-day-layout-container-width-value="320"
//        data-day-layout-gutter-value="6"
//        data-day-layout-min-width-value="120">
//
//     <div class="shift"
//          data-day-layout-target="event"
//          data-id="A"
//          data-start-min="300"
//          data-end-min="1320"
//          style="position:absolute; top:...; height:...">
//     </div>
//     ...
//   </div>

export default class extends Controller {
  static targets = ["event"];

  static values = {
    containerWidth: { type: Number, default: 320 },
    gutter:         { type: Number, default: 6 },
    minWidth:       { type: Number, default: 120 },
  };

  connect() {
    this.#layout();
  }

  // Re-run if values change (e.g. container resized via ResizeObserver outside).
  containerWidthValueChanged() { if (this.hasEventTarget) this.#layout(); }

  // ── private ──────────────────────────────────────────────────────────────

  #layout() {
    const events = this.eventTargets.map(el => ({
      id:       el.dataset.id,
      startMin: parseInt(el.dataset.startMin, 10),
      endMin:   parseInt(el.dataset.endMin,   10),
      element:  el,
    }));

    const { results, needsHorizontalScroll } = layoutDayEvents(events, {
      containerWidth: this.containerWidthValue,
      gutter:         this.gutterValue,
      minWidth:       this.minWidthValue,
    });

    for (const r of results) {
      r.element.style.left  = `${r.leftPx}px`;
      r.element.style.width = `${r.widthPx}px`;
    }

    this.element.classList.toggle("needs-scroll", needsHorizontalScroll);
  }
}
