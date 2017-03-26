SetupMsgNotifier = require './magic-token.coffee'
{CompositeDisposable} = require 'atom'

module.exports =
  config:
    commit:
      title: 'Append magic token to commit message files?'
      description: 'If enabled, the token `##ATOM EDIT COMPLETE##` will be appended to any `COMMIT_EDITMSG` file opened in Atom when that file is closed. If disabled, the user will have to manually signal the completion of the edited message by entering `quit` or `done` at the command line.'
      type: 'boolean'
      default: true
      order: 1
    tag:
      title: 'Append magic token to tag message files?'
      description: 'If enabled, the token `##ATOM EDIT COMPLETE##` will be appended to any `TAG_EDITMSG` file opened in Atom when that file is closed. If disabled, the user will have to manually signal the completion of the edited message by entering `quit` or `done` at the command line.'
      type: 'boolean'
      default: true
      order: 2
    merge:
      title: 'Append magic token to merge message files?'
      description: 'If enabled, the token `##ATOM EDIT COMPLETE##` will be appended to any `MERGE_MSG` file opened in Atom when that file is closed. If disabled, the user will have to manually signal the completion of the edited message by entering `quit` or `done` at the command line.'
      type: 'boolean'
      default: true
      order: 3
    rebase:
      title: 'Append magic token to rebase todo files?'
      description: 'If enabled, the token `##ATOM EDIT COMPLETE##` will be appended to any `git-rebase-todo` file opened in Atom when that file is closed. If disabled, the user will have to manually signal the completion of the rebase todo by entering `quit` or `done` at the command line.'
      type: 'boolean'
      default: true
      order: 4
    diff:
      title: 'Append magic token to diff files?'
      description: 'If enabled, the token `##ATOM EDIT COMPLETE##` will be appended to any `*.diff` file opened in Atom when that file is closed. If disabled, the user will have to manually signal the completion of the diff edit by entering `quit` or `done` at the command line.'
      type: 'boolean'
      default: false
      order: 5

  # Called upon Atom initial load
  activate: (state) ->
    @smn = new SetupMsgNotifier()
    @setting_listeners = new CompositeDisposable()

    @_setup()
    true

  # Clean up
  deactivate: ->
    @smn.destroy()
    @setting_listeners.dispose()

    true

  # Set up for all editors to be screened for commit messages.
  _setup: ->
    @_setup_one('git-edit-atom.commit', 'COMMIT_EDITMSG', true)
    @_setup_one('git-edit-atom.tag', 'TAG_EDITMSG', true)
    @_setup_one('git-edit-atom.merge', 'MERGE_MSG', true)
    @_setup_one('git-edit-atom.rebase', 'git-rebase-todo', true)
    @_setup_one('git-edit-atom.diff', 'diff', false)
    true

  _setup_one: (setting_key, token_key, isbasename) ->
    # Set up a settings listener for each target...
    setting_lambda = (value) =>
      @_update_one(setting_key, token_key, isbasename)
    setting_listener = atom.config.onDidChange setting_key, setting_lambda
    @setting_listeners.add(setting_listener)

    # ... and initialize the magic token appending listeners
    # (add or don't add, depending on current settings)
    @_update_one(setting_key, token_key, isbasename)
    true

  # Update the magic token appending listeners (add or remove)
  # based on the current settings
  _update_one: (setting_key, token_key, isbasename) ->
    if atom.config.get setting_key
      @smn.register(token_key, isbasename)
    else
      @smn.deregister(token_key)
    true
