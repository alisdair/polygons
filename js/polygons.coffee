class Point
  @list: (points) ->
    new Point(p...) for p in points

  constructor: (@x, @y) ->

class Line
  constructor: (@start, @end) ->

  draw: (context) ->
    context.beginPath()
    context.moveTo @start.x, @start.y
    context.lineTo @end.x, @end.y
    context.stroke()

class Polygon
  constructor: (@vertices) ->
    @closed = false
    @filled = false
    @colour = "hsl(0, 60%, 60%)"

  draw: (context) ->
    return if @vertices.length < 1
    context.beginPath()
    context.fillStyle = context.strokeStyle = @colour
    context.lineTo v.x, v.y for v in @vertices
    context.lineTo @vertices[0].x, @vertices[0].y if @closed
    context.stroke()
    context.globalAlpha = 0.5
    context.fill() if @filled

  # http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
  contains: (point) ->
    return false unless @vertices.length > 0
    crossings = 0
    b = @vertices[@vertices.length - 1]
    for a in @vertices
      intersect = ((a.y > point.y) != (b.y > point.y))
      below = point.x < (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x
      crossings++ if intersect && below
      b = a
    crossings % 2 == 1

cursor = (canvas, e) ->
  o = canvas.offset()
  db = document.body
  de = document.documentElement
  [e.clientX + db.scrollLeft + de.scrollLeft - Math.floor(o.left),
   e.clientY + db.scrollTop + de.scrollTop - Math.floor(o.top) + 1]

$(document).ready ->
  canvas = $("canvas")
  context = canvas[0].getContext("2d")
  context.lineWidth = 2.5

  polygon = new Polygon []
  line = undefined
  polygons = []

  append = (e) ->
    polygon.vertices.push new Point (cursor canvas, e)...

  extend = (e) ->
    return unless polygon.vertices.length > 0
    start = polygon.vertices[polygon.vertices.length - 1]
    end = new Point (cursor canvas, e)...
    line = new Line(start, end)

  intersect = (e) ->
    point = new Point (cursor canvas, e)...
    p.filled = p.contains point for p in polygons

  close = (e) ->
    return unless polygon?
    polygon.closed = true
    polygon.colour = "hsl(#{~~(Math.random() * 360)}, 60%, 60%)"
    polygons.push polygon
    polygon = new Polygon []
    line = undefined
  
  canvas.mouseup append
  canvas.mousemove extend
  canvas.mousemove intersect
  canvas.keydown close

  canvas.attr("tabindex", 0)
  canvas.focus

  canvas.on "selectstart", -> false

  (render = ->
    requestAnimationFrame render
    context.clearRect 0, 0, canvas.width(), canvas.height()
    p.draw(context) for p in polygons
    polygon.draw(context) if polygon?
    line.draw(context) if line?
  )()
