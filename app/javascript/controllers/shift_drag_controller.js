import { Controller } from "@hotwired/stimulus";

// data-controller="shift-drag"
// Enables admin users to:
//   - Drag-and-drop weekly shifts to new days/times.
//   - Resize shifts by dragging the top edge (start time) or bottom edge (end time).
// Uses the Pointer Events API for cross-device (mouse + touch) support.
// After a successful drop or resize, reloads the page via Turbo.visit.
export default class extends Controller {
  static values = {
    rowHeight: Number, // Meeting::HOUR_HEIGHT_IN_PX (50)
  };

  connect() {
    this._drag   = null;
    this._resize = null;

    this._onPointerMove = this._onPointerMove.bind(this);
    this._onPointerUp   = this._onPointerUp.bind(this);
    this._onResizeMove  = this._onResizeMove.bind(this);
    this._onResizeUp    = this._onResizeUp.bind(this);

    this.element.addEventListener("pointerdown", this._handlePointerDown.bind(this));
  }

  disconnect() {
    this._cancelDrag();
    this._cancelResize();
  }

  // ── Pointer Down Dispatcher ────────────────────────────────────────────────
  // Resize handles take priority so clicking them never starts a drag.

  _handlePointerDown(e) {
    const handle = e.target.closest(".resize-handle");
    if (handle) {
      this._startResize(e, handle);
      return;
    }

    const shift = e.target.closest(".weekly-meeting.admin");
    if (!shift) return;
    if (e.button !== undefined && e.button !== 0) return;

    e.preventDefault();
    e.stopPropagation();

    const meetingId   = shift.dataset.meetingId;
    const durationSec = parseInt(shift.dataset.meetingDuration, 10);
    if (!meetingId || !durationSec) return;

    const rect         = shift.getBoundingClientRect();
    const durationMs   = durationSec * 1000;
    const shiftHeightPx = (durationSec / 3600) * this.rowHeightValue;

    this._drag = {
      meetingId,
      durationMs,
      shiftHeightPx,
      originalEl: shift,
      ghost: this._createGhost(shift, rect),
      dropIndicator: null,
      offsetX: e.clientX - rect.left,
      offsetY: e.clientY - rect.top,
      startX: e.clientX,
      startY: e.clientY,
      hasMoved: false,
      currentDropColumn: null,
      pendingStart: null,
    };

    shift.classList.add("dragging");
    document.body.style.userSelect = "none";

    document.addEventListener("pointermove", this._onPointerMove, { passive: false });
    document.addEventListener("pointerup",    this._onPointerUp);
    document.addEventListener("pointercancel", this._onPointerUp);
  }

  // ── Ghost Element ─────────────────────────────────────────────────────────

  _createGhost(shift, rect) {
    const ghost = shift.cloneNode(true);
    ghost.classList.add("drag-ghost");
    ghost.classList.remove("dragging", "admin");
    ghost.style.cssText = "";
    ghost.style.position = "fixed";
    ghost.style.width    = `${rect.width}px`;
    ghost.style.height   = `${rect.height}px`;
    ghost.style.left     = `${rect.left}px`;
    ghost.style.top      = `${rect.top}px`;
    ghost.style.margin   = "0";
    ghost.style.pointerEvents   = "none";
    ghost.style.zIndex          = "99999";
    ghost.style.backgroundColor = shift.style.backgroundColor;
    document.body.appendChild(ghost);
    return ghost;
  }

  // ── Drop Indicator ────────────────────────────────────────────────────────

  _createDropIndicator(col, topPx, heightPx) {
    if (this._drag.dropIndicator) this._drag.dropIndicator.remove();

    const el = document.createElement("div");
    el.className     = "drop-indicator";
    el.style.top     = `${topPx}px`;
    el.style.height  = `${heightPx}px`;
    col.appendChild(el);
    this._drag.dropIndicator = el;
  }

  _removeDropIndicator() {
    if (this._drag?.dropIndicator) {
      this._drag.dropIndicator.remove();
      this._drag.dropIndicator = null;
    }
  }

  // ── Drag Move ─────────────────────────────────────────────────────────────

  _onPointerMove(e) {
    if (!this._drag) return;
    e.preventDefault();

    const { ghost, offsetX, offsetY, startX, startY } = this._drag;

    if (!this._drag.hasMoved) {
      const dx = e.clientX - startX;
      const dy = e.clientY - startY;
      if (dx * dx + dy * dy > 25) this._drag.hasMoved = true;
    }

    ghost.style.left = `${e.clientX - offsetX}px`;
    ghost.style.top  = `${e.clientY - offsetY}px`;

    this._updateDropTarget(e.clientX, e.clientY);
  }

  _updateDropTarget(cursorX, cursorY) {
    this._drag.ghost.style.display = "none";
    const el = document.elementFromPoint(cursorX, cursorY);
    this._drag.ghost.style.display = "";

    const col = el?.closest(".week-day.meetings");

    if (col !== this._drag.currentDropColumn) {
      this._drag.currentDropColumn?.classList.remove("drop-target");
      this._removeDropIndicator();
      col?.classList.add("drop-target");
      this._drag.currentDropColumn = col;
    }

    if (!col) return;

    const colRect       = col.getBoundingClientRect();
    const shiftTopInCol = cursorY - this._drag.offsetY - colRect.top;
    const { snappedTopPx, snappedHour, snappedMinute } = this._snapToGrid(shiftTopInCol);

    this._drag.pendingStart = { newHour: snappedHour, newMinute: snappedMinute };
    this._createDropIndicator(col, snappedTopPx, this._drag.shiftHeightPx);
  }

  // ── Snap to 30-min Grid ───────────────────────────────────────────────────

  _snapToGrid(topPx) {
    const rowHeight             = this.rowHeightValue; // px per hour (50)
    const minutesPerPx          = 60 / rowHeight;
    const rawMinutesFromStart   = Math.max(0, topPx * minutesPerPx);
    const snappedMinutesFromStart = Math.round(rawMinutesFromStart / 30) * 30;

    const totalHoursOffset = Math.floor(snappedMinutesFromStart / 60);
    const snappedMinute    = snappedMinutesFromStart % 60;
    const snappedHour      = Math.min(8 + totalHoursOffset, 22);

    const snappedTopPx = ((snappedHour - 8) * 60 + snappedMinute) / minutesPerPx;

    return { snappedTopPx, snappedHour, snappedMinute };
  }

  // ── Drag End ──────────────────────────────────────────────────────────────

  _onPointerUp(e) {
    if (!this._drag) return;

    const { meetingId, durationMs, originalEl, ghost, currentDropColumn, pendingStart, hasMoved } =
      this._drag;

    this._removeDropIndicator();
    this._cleanupDrag(originalEl, ghost);

    if (hasMoved) {
      const suppressClick = (ev) => {
        ev.preventDefault();
        ev.stopPropagation();
        document.removeEventListener("click", suppressClick, true);
      };
      document.addEventListener("click", suppressClick, true);
    }

    if (!hasMoved || !currentDropColumn || !pendingStart) {
      this._drag = null;
      return;
    }

    const newDate = currentDropColumn.dataset.date;
    if (!newDate) { this._drag = null; return; }

    const { newHour, newMinute } = pendingStart;
    const pad         = (n) => String(n).padStart(2, "0");
    const newStartISO = `${newDate}T${pad(newHour)}:${pad(newMinute)}:00`;
    const newStart    = new Date(newStartISO);
    const newEnd      = new Date(newStart.getTime() + durationMs);

    this._drag = null;
    this._patchMeeting(meetingId, newStart, newEnd);
  }

  _cleanupDrag(originalEl, ghost) {
    originalEl?.classList.remove("dragging");
    ghost?.remove();
    this._drag?.currentDropColumn?.classList.remove("drop-target");
    document.body.style.userSelect = "";
    document.removeEventListener("pointermove", this._onPointerMove);
    document.removeEventListener("pointerup",    this._onPointerUp);
    document.removeEventListener("pointercancel", this._onPointerUp);
  }

  _cancelDrag() {
    if (this._drag) {
      this._removeDropIndicator();
      this._cleanupDrag(this._drag.originalEl, this._drag.ghost);
      this._drag = null;
    }
  }

  // ── Resize: Start ─────────────────────────────────────────────────────────

  _startResize(e, handle) {
    const shift = handle.closest(".weekly-meeting.admin");
    if (!shift) return;
    if (e.button !== undefined && e.button !== 0) return;

    e.preventDefault();
    e.stopPropagation();

    const meetingId = shift.dataset.meetingId;
    const col       = shift.closest(".week-day.meetings");
    if (!meetingId || !col) return;

    const isTop       = handle.classList.contains("resize-handle--top");
    const currentTop  = parseFloat(shift.style.top) || 0;
    // style.height is set by Ruby; fall back to rendered height if absent
    const currentHeight = parseFloat(shift.style.height) || shift.getBoundingClientRect().height;

    this._resize = {
      shift,
      meetingId,
      isTop,
      col,
      currentTop,
      currentBottom:   currentTop + currentHeight,
      startMin: parseInt(shift.dataset.startMin, 10),
      endMin:   parseInt(shift.dataset.endMin,   10),
      pendingStartMin: null,
      pendingEndMin:   null,
    };

    shift.classList.add("resizing");
    document.body.style.userSelect = "none";

    document.addEventListener("pointermove", this._onResizeMove, { passive: false });
    document.addEventListener("pointerup",    this._onResizeUp);
    document.addEventListener("pointercancel", this._onResizeUp);
  }

  // ── Resize: Move ──────────────────────────────────────────────────────────

  _onResizeMove(e) {
    if (!this._resize) return;
    e.preventDefault();

    const { shift, isTop, col, currentTop, currentBottom } = this._resize;
    const colRect   = col.getBoundingClientRect();
    const yInCol    = e.clientY - colRect.top;
    const { snappedTopPx, snappedHour, snappedMinute } = this._snapToGrid(yInCol);
    const snappedMin  = snappedHour * 60 + snappedMinute;
    const minHeightPx = this.rowHeightValue * 0.5; // enforce 30-min minimum

    if (isTop) {
      // Top handle: keep bottom fixed, move top up/down
      if (snappedTopPx < currentBottom - minHeightPx) {
        shift.style.top    = `${snappedTopPx}px`;
        shift.style.height = `${currentBottom - snappedTopPx}px`;
        this._resize.pendingStartMin = snappedMin;
      }
    } else {
      // Bottom handle: keep top fixed, stretch/shrink bottom
      if (snappedTopPx > currentTop + minHeightPx) {
        shift.style.height = `${snappedTopPx - currentTop}px`;
        this._resize.pendingEndMin = snappedMin;
      }
    }
  }

  // ── Resize: End ───────────────────────────────────────────────────────────

  _onResizeUp() {
    if (!this._resize) return;

    const { shift, meetingId, col, startMin, endMin, pendingStartMin, pendingEndMin } = this._resize;

    shift.classList.remove("resizing");
    document.body.style.userSelect = "";
    document.removeEventListener("pointermove", this._onResizeMove);
    document.removeEventListener("pointerup",    this._onResizeUp);
    document.removeEventListener("pointercancel", this._onResizeUp);

    const newStartMin = pendingStartMin ?? startMin;
    const newEndMin   = pendingEndMin   ?? endMin;
    this._resize = null;

    if (newStartMin === startMin && newEndMin === endMin) return;
    if (newStartMin >= newEndMin) return;

    const newDate = col.dataset.date;
    if (!newDate) return;

    const pad    = (n) => String(n).padStart(2, "0");
    const toISO  = (min) => `${newDate}T${pad(Math.floor(min / 60))}:${pad(min % 60)}:00`;

    this._patchMeeting(meetingId, new Date(toISO(newStartMin)), new Date(toISO(newEndMin)));
  }

  _cancelResize() {
    if (this._resize) {
      this._resize.shift?.classList.remove("resizing");
      document.body.style.userSelect = "";
      document.removeEventListener("pointermove", this._onResizeMove);
      document.removeEventListener("pointerup",    this._onResizeUp);
      document.removeEventListener("pointercancel", this._onResizeUp);
      this._resize = null;
    }
  }

  // ── PATCH Meeting ─────────────────────────────────────────────────────────

  _patchMeeting(meetingId, startTime, endTime) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
    const url       = `/meetings/${meetingId}`;

    const fmt = (d) => {
      const pad = (n) => String(n).padStart(2, "0");
      return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
    };

    const body = new URLSearchParams({
      "meeting[start_time]": fmt(startTime),
      "meeting[end_time]":   fmt(endTime),
    });

    fetch(url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        Accept:         "application/json",
        "X-CSRF-Token": csrfToken,
      },
      credentials: "same-origin",
      body: body.toString(),
    })
      .then((res) => {
        if (res.ok) {
          Turbo.visit(window.location.href, { action: "replace" });
        } else {
          res.json().then((data) => {
            const msg = Object.values(data || {}).flat().join(", ") || "Failed to update shift.";
            this._showError(msg);
          });
        }
      })
      .catch(() => {
        this._showError("Network error — shift not updated.");
      });
  }

  // ── Error Toast ───────────────────────────────────────────────────────────

  _showError(message) {
    const el = document.createElement("div");
    el.className = "shift-drag-error";
    el.textContent = message;
    Object.assign(el.style, {
      position:     "fixed",
      bottom:       "1.5rem",
      left:         "50%",
      transform:    "translateX(-50%)",
      background:   "#dc2626",
      color:        "#fff",
      padding:      "0.5rem 1.25rem",
      borderRadius: "0.5rem",
      fontWeight:   "600",
      zIndex:       "10000",
      boxShadow:    "0 4px 16px rgba(0,0,0,0.25)",
      animation:    "shiftEnter 0.2s ease-out both",
    });
    document.body.appendChild(el);
    setTimeout(() => el.remove(), 3500);
  }
}
