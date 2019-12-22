##! Import Standard Headers
import math

##! Dependencies Headers
import ui_workflow_nim

##! Project Headers
import ../utils/utility

proc loadingIndicatorCircle*(label: cstring, indicatorRadius: cfloat, mainColor: ImVec4, backdropColor: ImVec4,
circleCount: cint, speed: cfloat) =
  let
    pos = igGetCursorScreenPos()
    circleRadius = indicatorRadius / 10.0
    t = igGetTime()
    degreeOffset = 2.0 * PI / circleCount.float

  for i in countTo(circleCount):
    let
      idxF = i.float
      x = indicatorRadius * sin(degreeOffset * idxF)
      y = indicatorRadius * cos(degreeOffset * idxF)
      growth = max(0.0, sin(t * speed - idxF * degreeOffset))
      color = ImVec4(x: mainColor.x * growth + backdropColor.x * (1.0f - growth), y: mainColor.y * growth +
          backdropColor.y * (1.0f - growth), z: mainColor.z * growth + backdropColor.z * (1.0f - growth), w: 1.0f)
    igGetWindowDrawList().addCircleFilled(ImVec2(x: pos.x + indicatorRadius + x, y: pos.y + indicatorRadius - y),
        circleRadius + growth * circleRadius, igGetColorU32(color))
