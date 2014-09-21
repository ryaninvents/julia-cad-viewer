{View} = require 'atom'

THREE = require '../vendor/three'
require('../vendor/OrbitControls') THREE

module.exports =
class JuliaCadViewerView extends View
  @content: ->
    @div =>
      @div class: "viewer", outlet: "threeContainer"

  initialize: (serializeState) ->
    atom.workspaceView.command "julia-cad-viewer:show", => @toggle()
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
    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize(window.innerWidth, window.innerHeight)
    @threeContainer.empty()
    @threeContainer.append(@renderer.domElement)

    @prepareScene @scene
    @enableControl(@camera)

  prepareScene: (scene) ->
    geometry = new THREE.BoxGeometry(30, 30, 30)
    material = new THREE.MeshLambertMaterial(color: 0x00ff00)

    cube = new THREE.Mesh( geometry, material )
    scene.add cube

    light = new THREE.AmbientLight(0x404040)
    scene.add( light )

    directionalLight = new THREE.DirectionalLight(0xffffff, 0.5)
    directionalLight.position.set(1, 3, 2)
    scene.add directionalLight

    directionalLight = new THREE.DirectionalLight(0xffffff, 0.1)
    directionalLight.position.set(-3, -1, -2)
    scene.add directionalLight

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
