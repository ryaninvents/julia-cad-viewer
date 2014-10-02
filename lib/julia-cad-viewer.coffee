JuliaCadViewerView = require './julia-cad-viewer-view'

module.exports =
  juliaCadViewerView: null
  configDefaults:
    juliaPath: '/usr/bin/julia'

  activate: (state) ->
    @juliaCadViewerView = new JuliaCadViewerView()
    atom.workspaceView.command 'julia-cad-viewer:show', =>
      program = atom.workspace.getActivePaneItem().getText()
      console.log('PROGRAM!',program)
      @juliaCadViewerView.bridge.send program
      atom.workspace.open 'cad-jl://test'
    atom.workspace.registerOpener (uri) =>
      return unless uri.match /^cad-jl:\/\/.*$/
      @juliaCadViewerView

  deactivate: ->
    @juliaCadViewerView.destroy()

  serialize: ->
    juliaCadViewerViewState: @juliaCadViewerView.serialize()
