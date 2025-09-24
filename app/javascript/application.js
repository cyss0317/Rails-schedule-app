// Entry point for the build script in your package.json
import "@hotwired/turbo-rails";
import { Turbo } from "@hotwired/turbo-rails";

import { Application } from "@hotwired/stimulus";
import DrawerController from "./controllers/drawer_controller";

window.Stimulus = Application.start();
Stimulus.register("drawer", DrawerController);

// (optional) debug
// window.Stimulus.debug = true;
console.log("[app] application.js loaded");
Turbo.config.forms.confirm = (message, element) => {
  // optional debug:
  // console.log("[confirm]", { element, message });
  return window.confirm(message);
};