class Vertex
  @list: (vertices) ->
    new Vertex(v...) for v in vertices

  constructor: (@x, @y) ->

  draw: (context) ->
    context.beginPath()
    context.fillStyle = "#0c0"
    context.arc @x, @y, 5, 0, Math.PI*2, true
    context.fill()

  toString: ->
    "(#{@x}, #{y})"

class Line
  constructor: (@start, @end) ->

  draw: (context) ->
    context.beginPath()
    context.strokeStyle = "#999"
    context.moveTo @start.x, @start.y
    context.lineTo @end.x, @end.y
    context.stroke()

class Polygon
  constructor: (@vertices) ->
    @closed = false

  close: ->
    @closed = true

  draw: (context) ->
    return if @vertices.length < 1
    context.beginPath()
    context.strokeStyle = "#00b"
    context.lineTo v.x, v.y for v in @vertices
    context.lineTo @vertices[0].x, @vertices[0].y if @closed
    context.stroke()

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
  vertex = null
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

  point = (e) ->
    vertex = new Vertex (cursor canvas, e)...

  close = (e) ->
    append e
    polygon.close()
    line = null
    canvas.off "mouseup mousemove dblclick"
    canvas.mousedown point
  
  canvas.mouseup append
  canvas.mousemove extend
  canvas.dblclick close

  canvas.on "selectstart", -> false

  (render = ->
    requestAnimationFrame render
    context.clearRect 0, 0, canvas.width(), canvas.height()
    polygon.draw(context) if polygon
    line.draw(context) if line
    vertex.draw(context) if vertex
  )()