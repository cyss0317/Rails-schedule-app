import { Controller } from "@hotwired/stimulus";

// data-controller="weekly-calendar"
// Handles: current-time liner positioning, click-to-create meetings,
//          employee hours overflow toggle, same-meeting hover grouping
export default class extends Controller {
  static values = {
    locationId: Number,
    rowHeight: Number,
  };

  connect() {
    this._positionCurrentTimeLiner();
    this._setupTodayDateClick();
    this._setupAdminTableClick();
    this._setupEmployeeHoursToggle();
    this._setupMeetingHoverGrouping();
  }

  // ── Current Time Liner ────────────────────────────────────────────────────

  _positionCurrentTimeLiner() {
    const liner = this.element.querySelector(".current-time-liner");
    if (!liner) return;

    const now = new Date();
    const hour = now.getHours();
    const minutes = now.getMinutes();
    const topPx =
      (hour - 8) * this.rowHeightValue + (minutes / 60) * this.rowHeightValue;
    liner.style.top = `${topPx}px`;

    const adminLiner = this.element.querySelector(".current-time-liner-admin");
    if (adminLiner) {
      const snapTime = new Date(now);
      snapTime.setMinutes(0, 0, 0);
      adminLiner.addEventListener("click", (e) => {
        e.stopPropagation();
        window.location.href = `/locations/${this.locationIdValue}/meetings/new?start_date=${encodeURIComponent(snapTime)}`;
      });
    }
  }

  _setupTodayDateClick() {
    const todayBtn = this.element.querySelector(".today-date");
    const adminLiner = this.element.querySelector(".current-time-liner-admin");
    if (!todayBtn || !adminLiner) return;

    todayBtn.addEventListener("click", () => {
      const y =
        adminLiner.getBoundingClientRect().top + window.pageYOffset - 200;
      window.scrollTo({ top: y, behavior: "smooth" });
    });
  }

  // ── Admin Table Click-to-Create ───────────────────────────────────────────

  _setupAdminTableClick() {
    const adminTables = this.element.querySelectorAll(".admin-table");
    adminTables.forEach((el) => {
      el.addEventListener("click", (e) => {
        // Ignore clicks on meeting blocks — they handle their own navigation
        if (e.target.closest(".weekly-meeting")) return;

        const rect = el.getBoundingClientRect();
        const yOffset = e.clientY - rect.top;
        const hour = 8 + Math.floor(yOffset / this.rowHeightValue);
        // Snap minutes to nearest :00 or :30
        const rawMinutes = (yOffset % this.rowHeightValue) / this.rowHeightValue * 60;
        const snappedMinutes = Math.round(rawMinutes / 30) * 30;
        const finalHour = snappedMinutes === 60 ? hour + 1 : hour;
        const finalMinute = snappedMinutes === 60 ? 0 : snappedMinutes;
        const clickedTime = `${finalHour}:${String(finalMinute).padStart(2, "0")}`;
        const date = el.dataset.date;

        window.location.href = `/locations/${this.locationIdValue}/meetings/new?start_date=${date} ${clickedTime}`;
      });
    });
  }

  // ── Employee Hours Overflow Toggle ────────────────────────────────────────

  _setupEmployeeHoursToggle() {
    const emptyTr = this.element.querySelector(".empty-tr");
    const employeeHours = this.element.querySelectorAll(".employee-hours");
    if (!emptyTr || !employeeHours.length) return;

    employeeHours.forEach((el) => {
      el.addEventListener("click", () => {
        emptyTr.classList.toggle("overflow-auto");
        emptyTr.classList.toggle("z-20");
      });
    });
  }

  // ── Same-Meeting Hover Grouping ───────────────────────────────────────────
  // All segments sharing a meeting ID class (e.g. "weekly-meeting-42") get
  // highlighted together — using event delegation on the container instead
  // of attaching a listener per-shift.

  _setupMeetingHoverGrouping() {
    this.element.addEventListener("mouseover", (e) => {
      const shift = e.target.closest(".weekly-meeting");
      if (!shift) return;

      const meetingClass = this._meetingClass(shift);
      if (!meetingClass) return;

      this.element.querySelectorAll(`.${meetingClass}`).forEach((el) => {
        el.classList.add("hovered");
      });
    });

    this.element.addEventListener("mouseleave", () => {
      this._clearHovered();
    });

    this.element.addEventListener("mouseout", (e) => {
      const shift = e.target.closest(".weekly-meeting");
      if (!shift) return;

      // Only clear when leaving the meeting group entirely
      const related = e.relatedTarget?.closest(".weekly-meeting");
      if (!related || this._meetingClass(related) !== this._meetingClass(shift)) {
        const meetingClass = this._meetingClass(shift);
        if (meetingClass) {
          this.element.querySelectorAll(`.${meetingClass}`).forEach((el) => {
            el.classList.remove("hovered");
          });
        }
      }
    });
  }

  _meetingClass(el) {
    return [...el.classList].find((c) => c.startsWith("weekly-meeting-") && c !== "weekly-meeting");
  }

  _clearHovered() {
    this.element.querySelectorAll(".weekly-meeting.hovered").forEach((el) => {
      el.classList.remove("hovered");
    });
  }
}
