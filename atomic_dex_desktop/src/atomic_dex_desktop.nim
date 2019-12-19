import atomic_dex_desktop/utils/assets
import atomic_dex_desktop/mm2/mm2
import atomic_dex_desktop/gui/gui
import ui_workflow_nim

proc main() =
  mm2.init_process()
  defer: mm2.close_process()
  var ctx = antara_ui_create("AtomicDex", 200, 200)
  defer: antara_ui_destroy(ctx)
  echo get_assets_path() & "/fonts/Ruda-Bold.ttf"
  antara_load_font(ctx, get_assets_path() & "/fonts/Ruda-Bold.ttf", 15.0)
  antara_awesome_load_font(ctx, get_assets_path() & "/fonts/fa-solid-900.ttf", 16.0)
  gui.set_komodo_style()
  while antara_is_running(ctx) == 0:
    antara_pre_update(ctx)
    #antara_show_demo(ctx)
    gui.update(ctx)
    antara_update(ctx)

when isMainModule:
  main()
