class Vertex
  @list: (vertices) ->
    new Vertex(v...) for v in vertices

  constructor: (@x, @y) ->
    @colour = "#0c0"

  draw: (context) ->
    context.beginPath()
    context.fillStyle = @colour
    context.arc @x, @y, 5, 0, Math.PI*2, true
    context.fill()

  toString: ->
    "(#{@x}, #{@y})"

class Line
  constructor: (@start, @end) ->

  draw: (context) ->
    context.beginPath()
    context.strokeStyle = "#999"
    context.moveTo @start.x, @start.y
    context.lineTo @end.x, @end.y
    context.stroke()

  toString: ->
    "#{@start}-#{@end}"

class Polygon
  constructor: (@vertices) ->
    @closed = false
    @filled = false

  close: ->
    @closed = true

  draw: (context) ->
    return if @vertices.length < 1
    context.beginPath()
    context.fillStyle = "#aaf"
    context.strokeStyle = "#00b"
    context.lineTo v.x, v.y for v in @vertices
    context.lineTo @vertices[0].x, @vertices[0].y if @closed
    context.stroke()
    context.fill() if @filled

  # http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
  contains: (point) ->
    inside  = false
    [i, j] = [0, @vertices.length - 1]
    while i < @vertices.length
      [a, b] = [@vertices[i], @vertices[j]]

      intersect = ((a.y > point.y) != (b.y > point.y))
      below = point.x < (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x
      inside = !inside if intersect && below

      j = i
      i += 1
    inside

cursor = (canvas, e) ->
  o = canvas.offset()
  db = document.body
  de = document.documentElement
  [e.clientX + db.scrollLeft + de.scrollLeft - Math.floor(o.left),
   e.clientY + db.scrollTop + de.scrollTop - Math.floor(o.top) + 1]

$(document).ready ->
  canvas = $("canvas")
  context = canvas[0].getContext("2d")

  vertices = []
  point = null
  line = null
  polygon = null

  append = (e) ->
    vertices.push new Vertex (cursor canvas, e)...
    polygon = new Polygon vertices

  extend = (e) ->
    return unless vertices.length > 0
    start = vertices[vertices.length - 1]
    end = new Vertex (cursor canvas, e)...
    line = new Line(start, end)

  circle = (e) ->
    point = new Vertex (cursor canvas, e)...
    point.colour = "#c00" unless polygon.contains point

  close = (e) ->
    polygon.close()
    line = null
    canvas.off "mouseup mousemove keydown"
    canvas.mousedown circle
  
  canvas.mouseup append
  canvas.mousemove extend
  canvas.keydown close
  canvas.attr("tabindex", 0)
  canvas.focus

  canvas.on "selectstart", -> false

  (render = ->
    requestAnimationFrame render
    context.clearRect 0, 0, canvas.width(), canvas.height()
    polygon.draw(context) if polygon
    line.draw(context) if line
    point.draw(context) if point
  )()