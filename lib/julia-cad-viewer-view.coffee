{View} = require 'atom'

THREE = require 'three'

module.exports =
class JuliaCadViewerView extends View
  @content: ->
    @div 'data-element':'3d-view'

  initialize: (serializeState) ->
    atom.workspaceView.command "julia-cad-viewer:show", => @toggle()
    @init3D()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "JuliaCadViewerView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
  getTitle: -> 'Julia CAD'
  getUri: -> 'cad-jl://test'
  init3D: ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera(75, 1, 1, 10000)
    @camera.position.z = 1000
    geometry = new THREE.BoxGeometry(200, 200, 200)
    material = new THREE.MeshBasicMaterial(
      color: 0xff0000
      wireframe: true
    )
    @mesh = new THREE.Mesh(geometry, material)
    @scene.add @mesh
    @renderer = new THREE.CanvasRenderer()
    @renderer.setSize 400,400 #window.innerWidth, window.innerHeight
    #document.body.appendChild renderer.domElement
    @find('[data-element="3d-view"]').append @renderer.domElement
    @animate()

  animate: ->
    requestAnimationFrame => @animate()
    @mesh.rotation.x += 0.01
    @mesh.rotation.y += 0.02
    @renderer.render @scene, @camera
