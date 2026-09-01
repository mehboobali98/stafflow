import { Application } from "@hotwired/stimulus"

import AnimateOnScrollController from "./animate_on_scroll_controller"
import DirtyFormController from "./dirty_form_controller"
import EventDateController from "./event_date_controller"
import NotificationCountController from "./notification_count_controller"
import SidebarController from "./sidebar_controller"
import SubdomainController from "./subdomain_controller"
import ToggleFieldController from "./toggle_field_controller"

// Registered by hand rather than swept up from the directory. The lazy-loading
// helpers that do the sweeping read an importmap or a webpack require.context -
// the second of which is what silently threw on every page of this application
// for two releases after the esbuild migration. esbuild resolves imports
// statically, so a name that is wrong here fails the build instead.
const application = Application.start()

application.register("animate-on-scroll", AnimateOnScrollController)
application.register("dirty-form", DirtyFormController)
application.register("event-date", EventDateController)
application.register("notification-count", NotificationCountController)
application.register("sidebar", SidebarController)
application.register("subdomain", SubdomainController)
application.register("toggle-field", ToggleFieldController)

export { application }
