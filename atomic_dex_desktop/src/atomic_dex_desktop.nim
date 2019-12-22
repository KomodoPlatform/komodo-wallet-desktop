import atomic_dex_desktop/utils/assets
import atomic_dex_desktop/mm2/mm2
import atomic_dex_desktop/gui/gui
import atomic_dex_desktop/coins/coins_cfg
import ui_workflow_nim

when defined(tsanitizer) and defined(macosx):
  {.passC: "-fsanitize=thread -fno-omit-frame-pointer"}
  {.passL: "-fsanitize=thread -fno-omit-frame-pointer"}

when defined(asanitizer) and defined(macosx):
  {.passC: "-fsanitize=address -fno-omit-frame-pointer"}
  {.passL: "-fsanitize=address -fno-omit-frame-pointer"}

proc guiMainLoop(ctx: ptr t_antara_ui) =
  while antara_is_running(ctx) == 0:
    antara_pre_update(ctx)
    gui.update(ctx)
    antara_update(ctx)

proc main() =
  coins_cfg.parseCfg()
  mm2.initProcess()
  defer: mm2.closeProcess()
  var ctx = antara_ui_create("AtomicDex", 200, 200)
  gui.init(ctx)
  defer: antara_ui_destroy(ctx)
  echo getAssetsPath() & "/fonts/Ruda-Bold.ttf"
  antara_load_font(ctx, getAssetsPath() & "/fonts/Ruda-Bold.ttf", 15.0)
  antara_awesome_load_font(ctx, getAssetsPath() & "/fonts/fa-solid-900.ttf", 16.0)
  gui.set_komodo_style()
  guiMainLoop(ctx)

when isMainModule:
  main()
