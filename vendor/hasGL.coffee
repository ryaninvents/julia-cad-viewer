hasGL = ->
  try
    canvas = document.createElement("canvas")
    return !!window.WebGLRenderingContext and (canvas.getContext("webgl") or canvas.getContext("experimental-webgl"))
  catch e
    return false
  return

module.exports = hasGL
