{View} = require 'atom'
JuliaBridge = require 'julia-bridge'

THREE = require '../vendor/three'
require('../vendor/OrbitControls') THREE

module.exports =
class JuliaCadViewerView extends View
  @content: ->
    @div =>
      @div class: "viewer", outlet: "threeContainer", resize: "onViewResize"

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

  updateGeom: ->
    (data) =>
      geom = new THREE.Geometry()
      geom.vertices.push.apply geom.vertices, data.vertices.map (v) ->
        new THREE.Vector3 v[0], v[1], v[2]
      data.faces.forEach (f) ->
        geom.faces.push new THREE.Face3 f
      geom.computeBoundingSphere()
      @scene.remove @cube
      @scene.add geom
      @cube = geom

  prepareScene: (scene) ->
    geometry = new THREE.BoxGeometry(30, 30, 30)
    material = new THREE.MeshLambertMaterial(color: 0x00ff00)

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

    setTimeout (=> @updateGeom()({vertices:[[0,0,0],[1,0,0],[0,0,1]],faces:[0,1,2]}), 1000)

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
