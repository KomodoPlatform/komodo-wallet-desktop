import ui_workflow_nim
import math

iterator countTo(n: int): int =
  var i = 0
  while i <= n:
    yield i
    inc i

proc loadingIndicatorCircle*(label: cstring, indicator_radius: cfloat, main_color: ImVec4, backdrop_color: ImVec4,
circle_count: cint, speed: cfloat) =
  let
    pos = igGetCursorScreenPos()
    circle_radius = indicator_radius / 10.0
    t = igGetTime()
    degree_offset = 2.0 * PI / circle_count.float

  for i in countTo(circle_count):
    let
      idx_f = i.float
      x = indicator_radius * sin(degree_offset * idx_f)
      y = indicator_radius * cos(degree_offset * idx_f)
      growth = max(0.0, sin(t * speed - idx_f * degree_offset))
      color = ImVec4(x: main_color.x * growth + backdrop_color.x * (1.0f - growth), y: main_color.y * growth +
          backdrop_color.y * (1.0f - growth), z: main_color.z * growth + backdrop_color.z * (1.0f - growth), w: 1.0f)
    igGetWindowDrawList().addCircleFilled(ImVec2(x: pos.x + indicator_radius + x, y: pos.y + indicator_radius - y),
        circle_radius + growth * circle_radius, igGetColorU32(color))
