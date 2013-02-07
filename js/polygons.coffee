class Vertex
  @list: (vertices) ->
    new Vertex(v...) for v in vertices

  constructor: (@x, @y) ->

class Polygon
  constructor: (@vertices) ->

  draw: (context) ->
    return if @vertices.length < 1
    context.beginPath()
    context.strokeStyle = "#00b"
    v = @vertices[@vertices.length - 1]
    context.moveTo v.x, v.y
    context.lineTo v.x, v.y for v in @vertices
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
  polygon = null
  refresh = true
  canvas.click (e) ->
    vertices.push new Vertex (cursor canvas, e)...
    polygon = new Polygon vertices
    refresh = true

  (render = ->
    requestAnimationFrame render
    return unless refresh
    refresh = false
    context.clearRect 0, 0, canvas.width(), canvas.height()
    polygon.draw(context) if polygon
  )()