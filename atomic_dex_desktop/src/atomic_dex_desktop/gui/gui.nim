##! Standard Import
import asyncdispatch
import atomics
import hashes
import json
import os
import sequtils
import strutils
import threadpool

##! Dependencies Import
import ui_workflow_nim

##! Project Import
import ../coins/coins_cfg
import ../cpp_bindings/folly/hashmap
import ../mm2/mm2
import ../utils/assets
import ../utils/utility
import ./widgets

var
  is_open = true
  curAssetTicker = "" 
  icons: ConcurrentReg[int, t_antara_image]
  enableableCoinsSelectList: seq[bool]

let
  bright_color = ImVec4(x: 0.0, y: 149.0 / 255.0, z: 143.0 / 255.0, w: 1.0)
  dark_color = ImVec4(x: 25.0 / 255.0, y: 40.0 / 255.0, z: 56.0 / 255.0, w: 1.0)

proc setKomodoStyle*() =
  var style = igGetStyle()
  style.frameRounding = 4.0
  style.grabRounding = 4.0
  style.windowRounding = 4.0
  style.windowPadding.x = 16.0
  style.windowPadding.y = 16.0
  style.framePadding.x = 8.0
  style.framePadding.y = 8.0
  style.displaySafeAreaPadding.x = 4.0
  style.displaySafeAreaPadding.y = 4.0
  style.displayWindowPadding.x = 4.0
  style.displayWindowPadding.y = 4.0
  style.itemSpacing.x = 4.0
  style.itemSpacing.y = 12.0
  style.itemInnerSpacing.x = 4.0
  style.itemInnerSpacing.y = 4.0
  style.indentSpacing = 4.0
  style.columnsMinSpacing = 4.0
  style.colors[ImGuiCol.Text.int32] = ImVec4(x: 0.95, y: 0.96, z: 0.98, w: 1.00)
  style.colors[ImGuiCol.TextDisabled.int32] = ImVec4(x: 0.36, y: 0.42,
                  z: 0.47, w: 1.00)
  style.colors[ImGuiCol.WindowBg.int32] = ImVec4(x: 0.11, y: 0.15,
                  z: 0.17, w: 1.00)
  style.colors[ImGuiCol.ChildBg.int32] = ImVec4(x: 0.15, y: 0.18, z: 0.22, w: 1.00)
  style.colors[ImGuiCol.PopupBg.int32] = ImVec4(x: 0.08, y: 0.08, z: 0.08, w: 0.94)
  style.colors[ImGuiCol.Border.int32] = ImVec4(x: 0.08, y: 0.10, z: 0.12, w: 1.00)
  style.colors[ImGuiCol.BorderShadow.int32] = ImVec4(x: 0.00, y: 0.00,
                  z: 0.00, w: 0.00)
  style.colors[ImGuiCol.FrameBg.int32] = ImVec4(x: 0.20, y: 0.25, z: 0.29, w: 1.00)
  style.colors[ImGuiCol.FrameBgHovered.int32] = ImVec4(x: 0.12, y: 0.20,
                  z: 0.28, w: 1.00)
  style.colors[ImGuiCol.FrameBgActive.int32] = ImVec4(x: 0.09, y: 0.12,
                  z: 0.14, w: 1.00)
  style.colors[ImGuiCol.TitleBgActive.int32] = ImVec4(x: 0.08, y: 0.10,
                  z: 0.12, w: 1.00)
  style.colors[ImGuiCol.TitleBgCollapsed.int32] = ImVec4(x: 0.00, y: 0.00,
                  z: 0.00, w: 0.51)
  style.colors[ImGuiCol.MenuBarBg.int32] = ImVec4(x: 0.15, y: 0.18,
                  z: 0.22, w: 1.00)
  style.colors[ImGuiCol.ScrollbarBg.int32] = ImVec4(x: 0.02, y: 0.02,
                  z: 0.02, w: 0.39)
  style.colors[ImGuiCol.ScrollbarGrab.int32] = ImVec4(x: 0.20, y: 0.25,
                  z: 0.29, w: 1.00)
  style.colors[ImGuiCol.ScrollbarGrabHovered.int32] = ImVec4(x: 0.18,
          y: 0.22,
          z: 0.25,
          w: 1.00)
  style.colors[ImGuiCol.ScrollbarGrabActive.int32] = ImVec4(x: 0.09,
          y: 0.21,
          z: 0.31,
          w: 1.00)
  style.colors[ImGuiCol.CheckMark.int32] = ImVec4(x: 0.28, y: 0.56,
                  z: 1.00, w: 1.00)
  style.colors[ImGuiCol.SliderGrab.int32] = ImVec4(x: 0.28, y: 0.56,
                  z: 1.00, w: 1.00)
  style.colors[ImGuiCol.SliderGrabActive.int32] = ImVec4(x: 0.37, y: 0.61,
  z: 1.00,
  w: 1.00)
  style.colors[ImGuiCol.Button.int32] = ImVec4(x: 0.20, y: 0.25, z: 0.29, w: 1.00)
  style.colors[ImGuiCol.ButtonHovered.int32] = ImVec4(x: 0.28, y: 0.56,
                  z: 1.00, w: 1.00)
  style.colors[ImGuiCol.ButtonActive.int32] = ImVec4(x: 0.06, y: 0.53,
                  z: 0.98, w: 1.00)
  style.colors[ImGuiCol.HeaderHovered.int32] = ImVec4(x: 0.26, y: 0.59,
                  z: 0.98, w: 0.80)
  style.colors[ImGuiCol.HeaderActive.int32] = ImVec4(x: 0.26, y: 0.59,
                  z: 0.98, w: 1.00)
  style.colors[ImGuiCol.Separator.int32] = ImVec4(x: 0.20, y: 0.25,
                  z: 0.29, w: 1.00)
  style.colors[ImGuiCol.SeparatorHovered.int32] = ImVec4(x: 0.10, y: 0.40,
  z: 0.75,
  w: 0.78)
  style.colors[ImGuiCol.SeparatorActive.int32] = ImVec4(x: 0.10, y: 0.40,
                  z: 0.75, w: 1.00)
  style.colors[ImGuiCol.ResizeGrip.int32] = ImVec4(x: 0.26, y: 0.59,
                  z: 0.98, w: 0.25)
  style.colors[ImGuiCol.ResizeGripHovered.int32] = ImVec4(x: 0.26,
  y: 0.59, z: 0.98,
  w: 0.67)
  style.colors[ImGuiCol.ResizeGripActive.int32] = ImVec4(x: 0.26, y: 0.59,
  z: 0.98,
  w: 0.95)
  style.colors[ImGuiCol.Tab.int32] = ImVec4(x: 0.11, y: 0.15, z: 0.17, w: 1.00)
  style.colors[ImGuiCol.TabHovered.int32] = ImVec4(x: 0.26, y: 0.59,
                  z: 0.98, w: 0.80)
  style.colors[ImGuiCol.TabActive.int32] = ImVec4(x: 0.20, y: 0.25,
                  z: 0.29, w: 1.00)
  style.colors[ImGuiCol.TabUnfocused.int32] = ImVec4(x: 0.11, y: 0.15,
                  z: 0.17, w: 1.00)
  style.colors[ImGuiCol.TabUnfocusedActive.int32] = ImVec4(x: 0.11,
          y: 0.15,
          z: 0.17,
          w: 1.00)
  style.colors[ImGuiCol.PlotLines.int32] = ImVec4(x: 0.61, y: 0.61,
                  z: 0.61, w: 1.00)
  style.colors[ImGuiCol.PlotLinesHovered.int32] = ImVec4(x: 1.00, y: 0.43,
  z: 0.35,
  w: 1.00)
  style.colors[ImGuiCol.PlotHistogram.int32] = ImVec4(x: 0.90, y: 0.70,
                  z: 0.00, w: 1.00)
  style.colors[ImGuiCol.PlotHistogramHovered.int32] = ImVec4(x: 1.00,
          y: 0.60,
          z: 0.00,
          w: 1.00)
  style.colors[ImGuiCol.TextSelectedBg.int32] = ImVec4(x: 0.26, y: 0.59,
                  z: 0.98, w: 0.35)
  style.colors[ImGuiCol.DragDropTarget.int32] = ImVec4(x: 1.00, y: 1.00,
                  z: 0.00, w: 0.90)
  style.colors[ImGuiCol.NavHighlight.int32] = ImVec4(x: 0.26, y: 0.59,
                  z: 0.98, w: 1.00)
  style.colors[ImGuiCol.NavWindowingHighlight.int32] = ImVec4(x: 1.00,
          y: 1.00,
          z: 1.00,
          w: 0.70)
  style.colors[ImGuiCol.NavWindowingDimBg.int32] = ImVec4(x: 0.80,
  y: 0.80, z: 0.80,
  w: 0.20)
  style.colors[ImGuiCol.ModalWindowDimBg.int32] = ImVec4(x: 0.80, y: 0.80,
  z: 0.80,
  w: 0.35)
  style.colors[ImGuiCol.TitleBg.int32] = dark_color
  style.colors[ImGuiCol.Header.int32] = bright_color

proc waitingView() =
  igText("Loading, please wait...")
  let
    radius = 30.0
    pos = ImVec2(x: igGetWindowWidth() * 0.5f - radius, y: igGetWindowHeight() * 0.5f - radius)
  igSetCursorPos(pos)
  when not defined(windows):
    loadingIndicatorCircle("foo", radius, bright_color, dark_color, 9, 1.5)


proc mainMenuBar() =
  if igBeginMenuBar():
    if igMenuItem("Open", "Ctrl+A"):
      echo "Open"
    igEndMenuBar()
  else:
    echo "Nop"

proc portfolioEnableCoinView() =
  if igButton("Enable a coin"):
    igOpenPopup("Enable coins")
  var 
    popupIsOpen = true
    close = false
  if igBeginPopupModal("Enable coins", addr popupIsOpen, (ImGuiWindowFlags.AlwaysAutoResize.int32 or
      ImGuiWindowFlags.NoMove.int32).ImGuiWindowFlags):
    var coins = get_enableable_coins()
    igText(coins.len == 0 ?  "All coins are already enabled!" ! "Select the coins you want to add to your portfolio.")
    if coins.len == 0:
      igSeparator()
    if coins.len > enableableCoinsSelectList.len:
      enableableCoinsSelectList.setLen(coins.len)
      enableableCoinsSelectList.applyIt(false)
    for i, coin in coins:
      if igSelectable(coin["name"].getStr & " (" & coin["coin"].getStr & ")", enableableCoinsSelectList[i], ImGuiSelectableFlags.DontClosePopups):
        enableableCoinsSelectList[i] = enableableCoinsSelectList[i] == false
    if coins.len == 0 and igButton("Close"):
        close = true
    else:
      if igButton("Enable", ImVec2(x: 120.0, y: 0.0)):
        for i, v in enableableCoinsSelectList:
            if v == true:
              spawn enable_coin(coins[i]["coin"].getStr)
        close = true
      igSameLine()
      if igButton("Cancel", ImVec2(x: 120.0, y: 0.0)):
        close = true
    if not popupIsOpen or close:
      enableableCoinsSelectList.applyIt(false)
      igCloseCurrentPopup()
    igEndPopup()

proc portfolioGuiCoinNameImg(ticker: string, name: string = "", name_first = false) =
  let 
    icon = icons.at(ticker.hash)
    text = name.len > 0 ? name ! ticker
  if name_first:
    igTextWrapped(text)
    igSameLine()
    igSetCursorPosX(igGetCursorPosX() + 5.0)
  let 
    origTextPos = ImVec2(x: igGetCursorPosX(), y: igGetCursorPosY())
    customImgSize = icon.height.float32 * 0.8
  igSetCursorPos(ImVec2(x: origTextPos.x, y: origTextPos.y - (customImgSize - igGetFont().fontSize * 1.15) * 0.5))
  igImage(ImTextureID(cast[pointer](cast[ptr cuint](icon.id))), ImVec2(x: customImgSize, y: customImgSize))
  if name_first == false:
    var posAfterImg = ImVec2(x: igGetCursorPosX(), y: igGetCursorPosY())
    igSameLine()
    igSetCursorPos(origTextPos)
    igSetCursorPosX(igGetCursorPosX() + customImgSize + 5.0)
    igTextWrapped(text)
    igSetCursorPos(posAfterImg)

proc portfolioCoinsListView() =
  igBeginChild("left pane", ImVec2(x: 180, y: 0), true)
  var coins = getEnabledCoins()
  for i, v in(coins):
    if curAssetTicker.len == 0:
      curAssetTicker = v["coin"].getStr
    if igSelectable("##" & v["coin"].getStr, v["coin"].getStr == curAssetTicker):
      curAssetTicker = v["coin"].getStr
    igSameLine()
    portfolioGuiCoinNameImg(v["coin"].getStr)
  igEndChild()

proc portfolioView() =
  igText("Total Balance: 0 USD")
  portfolioEnableCoinView()
  portfolioCoinsListView()

proc mainView() =
  mainMenuBar()
  if igBeginTabBar("##Tabs", ImGuiTabBarFlags.None):
    if (igBeginTabItem("Portfolio")):
      portfolioView()
      igEndTabItem()
    igEndTabBar()

proc update*(ctx: ptr t_antara_ui) =
  igSetNextWindowSize(ImVec2(x: 1280, y: 720), ImGuiCond.FirstUseEver)
  igBegin("atomicDex", addr is_open, (ImGuiWindowFlags.NoCollapse.int32 or
      ImGuiWindowFlags.MenuBar.int32).ImGuiWindowFlags)
  if not is_open:
    antara_close_window(ctx)
  if mm2FullyRunning.load() == false:
    waitingView()
  else:
    mainView()
  igEnd()

proc loadImg(ctx: ptr t_antara_ui, id: string, path: string) {.async.} =
  discard icons.insertOrAssign(id.hash, antara_load_image_ws(ctx, path))

proc init*(ctx: ptr t_antara_ui) =
  var textures_path = getAssetsPath() & "/textures"
  for kind, path in walkDir(textures_path):
    var id = path.extractFilename.changeFileExt("").toUpperAscii
    asyncCheck loadImg(ctx, id, path)


