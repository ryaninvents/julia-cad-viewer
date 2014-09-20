{WorkspaceView} = require 'atom'
JuliaCadViewer = require '../lib/julia-cad-viewer'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "JuliaCadViewer", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('julia-cad-viewer')

  describe "when the julia-cad-viewer:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.julia-cad-viewer')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'julia-cad-viewer:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.julia-cad-viewer')).toExist()
        atom.workspaceView.trigger 'julia-cad-viewer:toggle'
        expect(atom.workspaceView.find('.julia-cad-viewer')).not.toExist()
