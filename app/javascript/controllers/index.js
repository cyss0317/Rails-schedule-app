import { Application } from "@hotwired/stimulus";
import DrawerController from "./drawer_controller";
import RoleToggleController from "./role_toggle_controller";

window.Stimulus = Application.start();
Stimulus.register("drawer", DrawerController);
Stimulus.register("role-toggle", RoleToggleController);