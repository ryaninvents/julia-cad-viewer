{View, $} = require 'atom'
JuliaBridge = require 'julia-bridge'

THREE = require '../vendor/three'
require('../vendor/OrbitControls') THREE
hasGL = require '../vendor/hasGL'

module.exports =
class JuliaCadViewerView extends View
  @content: ->
    @div =>
      @div class: "viewer", outlet: "threeContainer", resize: "onViewResize"

  initialize: (serializeState) ->
    atom.workspaceView.command "julia-cad-viewer:show", => @toggle()
    @bridge = new JuliaBridge
      juliaPath: atom.config.get "julia-cad-viewer.juliaPath"
    @threeContainer.on 'contextmenu', -> false
    @threeInit()
    @animate()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
      @threeInit()
      @animate()

  getTitle: -> 'Julia CAD'

  getUri: -> 'cad-jl://test'

  threeInit: ->
    @camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 10000)
    @camera.position.z = 100

    @scene = new THREE.Scene()
    @renderer = if hasGL() then new THREE.WebGLRenderer() else new THREE.CanvasRenderer()
    @renderer.setSize(window.innerWidth, window.innerHeight)
    @threeContainer.empty()
    @threeContainer.append(@renderer.domElement)

    @prepareScene @scene
    @enableControl(@camera)

  updateGeom: ->
    (data) =>
      geom = new THREE.Geometry()
      geom.vertices.push.apply geom.vertices, data.vertices.map (v) ->
        new THREE.Vector3 v[0], v[1], v[2]
      data.faces.forEach (f) ->
        geom.faces.push new THREE.Face3 f[0], f[1], f[2]
      geom.computeBoundingSphere()
      geom.computeFaceNormals()
      @scene.remove @cube
      @cube = new THREE.Mesh geom, @material
      @scene.add @cube

  prepareScene: (scene) ->
    geometry = new THREE.BoxGeometry(30, 30, 30)
    @material = material = new THREE.MeshLambertMaterial(color: 0x00ff00)

    @cube = cube = new THREE.Mesh( geometry, material )
    scene.add cube

    light = new THREE.AmbientLight(0x404040)
    scene.add( light )

    directionalLight = new THREE.DirectionalLight(0xffffff, 0.5)
    directionalLight.position.set(1, 3, 2)
    scene.add directionalLight

    directionalLight = new THREE.DirectionalLight(0xffffff, 0.1)
    directionalLight.position.set(-3, -1, -2)
    scene.add directionalLight

    @bridge.stream('model').onValues (model) =>
      @updateGeom() model

  onViewResize: () ->
    @renderer.setSize(window.innerWidth, window.innerHeight)

  enableControl: (camera) ->
    @controls = new THREE.OrbitControls(camera)
    @controls.damping = 0.2

  animate: =>
    try
      requestAnimationFrame @animate
    catch error
      console.error "The error was #{error}"
    @render()

  render: ->
    @controls.update()
    @renderer.render(@scene, @camera)
