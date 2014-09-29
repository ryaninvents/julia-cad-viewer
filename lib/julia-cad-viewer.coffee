JuliaCadView = require './julia-cad-viewer-view'

module.exports =
  juliaCadViewerView: null
  configDefaults:
    juliaPath: '/usr/bin/julia'

  activate: (state) ->
    #@juliaCadViewerView = new JuliaCadViewerView(state.juliaCadViewerViewState)
    atom.workspaceView.command 'julia-cad-viewer:show', ->
      atom.workspace.open 'cad-jl://test'
    atom.workspace.registerOpener (uri) ->
      return unless uri.match /^cad-jl:\/\/.*$/
      new JuliaCadView()

  deactivate: ->
    @juliaCadViewerView.destroy()

  serialize: ->
    juliaCadViewerViewState: @juliaCadViewerView.serialize()
