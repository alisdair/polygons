# This is a canvas toy which demonstrates hit detection for arbitrary
# polygons. Click anywhere to start creating a polygon. Click near the starting
# point to close it.
#
# Finished polygons are filled when the mouse cursor points at them. This is
# done using [Franklin's point in polygon algorithm][franklin].
#
# [franklin]: http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html

#### Points, Polygons, and Lines

# A point is a pair of cartesian co-ordinates, `x` and `y`.
class Point
  constructor: (@x, @y) ->

  distanceTo: (p) ->
    return null unless p?
    dx = p.x - @x
    dy = p.y - @y
    Math.sqrt dx * dx + dy * dy

# Polygons are described by a list of points, or vertices.
class Polygon
  constructor: (@vertices) ->
    @closed = false
    @filled = false
    @colour = "hsl(0, 60%, 60%)"

  # This is the interesting bit. I should really describe how this works.
  contains: (point) ->
    return false unless @vertices.length > 0
    crossings = 0
    b = @vertices[@vertices.length - 1]
    for a in @vertices
      crossings++ if ((a.y > point.y) != (b.y > point.y)) &&
                     point.x < (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x
      b = a
    crossings % 2 == 1

  # A polygon can draw itself into a canvas `context`.
  #
  # The polygon's outline is always drawn. If it is a closed polygon, a line is
  # drawn from its last vertex back to its first. If it is marked as filled,
  # the polygon has a translucent fill applied.
  draw: (context) ->
    return if @vertices.length < 1
    context.beginPath()
    context.fillStyle = context.strokeStyle = @colour
    context.lineTo v.x, v.y for v in @vertices
    context.lineTo @vertices[0].x, @vertices[0].y if @closed
    context.stroke()
    context.globalAlpha = 0.5
    context.fill() if @filled

# Lines are described by two points, `start` and `end`.
class Line
  constructor: (@start, @end) ->

  # The line object can draw itself. This method is only used when selecting the
  # next vertex of an in-progress polygon; the other lines of the polygon are
  # drawn by the polygon itself.
  draw: (context) ->
    context.beginPath()
    context.moveTo @start.x, @start.y
    context.lineTo @end.x, @end.y
    context.stroke()

#### Canvas and UI

# The user interface setup is handled in the window onload callback. This
# function closes over the state variables:
#
# * `canvas` is the canvas element we're drawing on, and `context` is its 2D
#   drawing context;
# * `polygon` is the polygon currently being drawn;
# * `line` is the extension line from the last vertex of `polygon` to the
#   cursor;
# * `polygons` is the collection of finished polygons.
window.onload = ->
  canvas = document.getElementsByTagName("canvas")[0]
  context = canvas.getContext("2d")
  context.lineWidth = 2.5

  polygon = new Polygon []
  line = undefined
  polygons = []

  # The cursor function calculates the position of a given mouse event `e`
  # relative to the `canvas` origin.
  cursor = (e) ->
    db = document.body
    de = document.documentElement
    x = e.clientX + db.scrollLeft + de.scrollLeft - Math.floor(canvas.offsetLeft)
    y = e.clientY + db.scrollTop + de.scrollTop - Math.floor(canvas.offsetTop) + 1
    p = new Point x, y
    d = p.distanceTo polygon.vertices[0]
    return if d? and d < 15 then polygon.vertices[0] else p

  # Now we define several functions to modify the state of the user interface.

  # Append: add a new vertex to the polygon at the position of `e`.
  append = (e) ->
    p = cursor e

    # If this is the first point, or it's not at the same position as the
    # first point, add it to the polygon.
    if polygon.vertices.length == 0 || p.distanceTo(polygon.vertices[0]) > 0
      polygon.vertices.push p
      return

    # Otherwise, this is the last point in the polgon. Close the current
    # polygon, choose a random colour, and add it to the list. Finally, start a
    # new polygon, and reset the extending line.
    polygon.closed = true
    polygon.colour = "hsl(#{~~(Math.random() * 360)}, 60%, 60%)"
    polygons.push polygon
    polygon = new Polygon []
    line = undefined

  # Extend: create a line in extension from the polygon's last vertex to the
  # position at `e`. This indicates where the user's next click will add a
  # vertex.
  extend = (e) ->
    return unless polygon.vertices.length > 0
    start = polygon.vertices[polygon.vertices.length - 1]
    end = cursor e
    line = new Line(start, end)

  # Intersect: calculate point-in-polygon intersection for the point at the
  # cursor and each of the existing polygons.
  intersect = (e) ->
    point = cursor e
    p.filled = p.contains point for p in polygons

  
  # We then attach each of the user interface functions to the mouse and
  # keyboard event handlers.
  #
  # * On mouse click, append to the polygon;
  # * On mouse move, draw an extending line, and recalculate intersections.
  canvas.onmouseup = append
  canvas.onmousemove = (event) ->
    extend event
    intersect event

  # Focus the canvas to catch keystrokes, and disable selection.
  canvas.focus()
  canvas.onselectstart = -> false

  # Shim for requestAnimationFrame, from [jrus][jrus]
  #
  # [jrus]: https://gist.github.com/paulirish/1579671/#comment-91474
  do ->
      w = window
      for vendor in ['ms', 'moz', 'webkit', 'o']
          break if w.requestAnimationFrame
          w.requestAnimationFrame = w["#{vendor}RequestAnimationFrame"]
          w.cancelAnimationFrame = (w["#{vendor}CancelAnimationFrame"] or
                                    w["#{vendor}CancelRequestAnimationFrame"])

      targetTime = 0
      w.requestAnimationFrame or= (callback) ->
          targetTime = Math.max targetTime + 16, currentTime = +new Date
          w.setTimeout (-> callback +new Date), targetTime - currentTime

      w.cancelAnimationFrame or= (id) -> clearTimeout id

  # The render loop:
  #
  # 1. Request an animation frame
  # 2. Clear the canvas.
  # 3. Draw each of the finished polygons in the list.
  # 4. Draw the new polygon.
  # 5. Draw the extending line if it exists.
  (render = ->
    window.requestAnimationFrame render
    context.clearRect 0, 0, canvas.width, canvas.height
    p.draw(context) for p in polygons
    polygon.draw(context) if polygon?
    line.draw(context) if line?
  )()
