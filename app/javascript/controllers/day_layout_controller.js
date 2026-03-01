import { Controller } from "@hotwired/stimulus";
import { layoutDayEvents } from "../utils/layout_day_events";

// day-layout controller
//
// Reads shift targets inside a single day column, runs the interval-column
// layout algorithm, and writes style.left / style.width as percentages.
// Vertical placement (top / height) is computed by Ruby and is untouched.
// A right gutter (default 15%) is always reserved so admins can click the
// empty area to create a new shift.
//
// Expected DOM shape:
//
//   <div class="meetings"
//        data-controller="day-layout"
//        data-day-layout-gutter-percent-value="1"
//        data-day-layout-right-gutter-percent-value="15">
//
//     <a class="weekly-meeting admin"
//        data-day-layout-target="event"
//        data-id="42"
//        data-start-min="540"
//        data-end-min="900"
//        style="position:absolute; top:...; height:...">
//     </a>
//     ...
//   </div>

export default class extends Controller {
  static targets = ["event"];

  static values = {
    gutterPercent:      { type: Number, default: 1.0 },
    rightGutterPercent: { type: Number, default: 15 },
  };

  connect() {
    this.#layout();
  }

  // ── private ────────────────────────────────────────────────────────────────

  #layout() {
    const events = this.eventTargets.map(el => ({
      id:       el.dataset.id,
      startMin: parseInt(el.dataset.startMin, 10),
      endMin:   parseInt(el.dataset.endMin,   10),
      element:  el,
    }));

    const { results } = layoutDayEvents(events, {
      gutterPercent:      this.gutterPercentValue,
      rightGutterPercent: this.rightGutterPercentValue,
    });

    for (const r of results) {
      r.element.style.left  = `${r.leftPercent.toFixed(4)}%`;
      r.element.style.width = `${r.widthPercent.toFixed(4)}%`;
    }
  }
}
