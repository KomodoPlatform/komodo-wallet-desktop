import osproc
import atomic_dex_desktop/utils/assets
import atomic_dex_desktop/mm2/mm2
import atomic_dex_desktop/gui/gui
import ui_workflow_nim
# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

proc main() =
  mm2.init_process()
  defer: mm2.close_process()
  var ctx = antara_ui_create("Hello", 200, 200)
  defer: antara_ui_destroy(ctx)
  gui.set_komodo_style()
  while antara_is_running(ctx) == 0:
    antara_pre_update(ctx)
    #antara_show_demo(ctx)
    gui.update(ctx)
    antara_update(ctx)

when isMainModule:
    main()