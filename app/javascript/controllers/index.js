import { Application } from "@hotwired/stimulus";
import DrawerController from "./drawer_controller";
import ActiveToggleController from "./active_toggle_controller";
import ModalController from "./modal_controller";
import ClipBoardController from "./clip_board_controller";
import MonthlyCalendarRowController from "./monthly_calendar_row_controller";
import WeeklyCalendarController from "./weekly_calendar_controller";
import ShiftDragController from "./shift_drag_controller";

window.Stimulus = Application.start();
Stimulus.register("drawer", DrawerController);
Stimulus.register("active-toggle", ActiveToggleController);
Stimulus.register("modal", ModalController);
Stimulus.register("clipboard", ClipBoardController);
Stimulus.register("monthly-calendar-row", MonthlyCalendarRowController);
Stimulus.register("weekly-calendar", WeeklyCalendarController);
Stimulus.register("shift-drag", ShiftDragController);
