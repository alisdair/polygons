class Vertex
  @list: (vertices) ->
    new Vertex(v...) for v in vertices

  constructor: (@x, @y) ->

class Polygon
  constructor: (@vertices) ->
    null if @vertices.length < 3

  draw: (context) ->
    context.beginPath()
    context.strokeStyle = "#00b"
    v = @vertices[@vertices.length - 1]
    context.moveTo v.x, v.y
    context.lineTo v.x, v.y for v in @vertices
    context.stroke()

$(document).ready ->
  canvas = $("canvas")[0]
  context = canvas.getContext("2d")
  triangle = new Polygon Vertex.list [[10, 10], [100, 60], [25, 100]]
  triangle.draw(context)
