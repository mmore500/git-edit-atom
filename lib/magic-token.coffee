{CompositeDisposable} = require 'atom'

module.exports =
class SetupMsgNotifier
  # set up registry for token_key disposables so they may be
  # destroyed on demand in the future
  constructor: ->
    @file_listeners = {}
    @close_listeners = {}
    true

  register: (token_key, isbasename) ->
    if isbasename
      # if recognizing targets by their basename
      res = atom.workspace.observeTextEditors(@_create_notif_bn(token_key))
    else
      # if recognizing targets by  extension
      res = atom.workspace.observeTextEditors(@_create_notif_ext(token_key))

    @file_listeners[token_key] = res

    true

  # Remove listeners
  deregister: (token_key) ->
    # File listeners look for files matching a particular pattern in order
    # to tag a close listener on the file tab
    @file_listeners[token_key]?.dispose()
    # Delete the key from the registry so there is room to add a new disposable
    # if the user re-registers the key
    delete @file_listeners[token_key]

    # Close listeners watch a particular file tab in order to write the magic
    # token on the end of the file on close
    @close_listeners[token_key]?.dispose()
    # Delete the key from the registry so there is room to add a new disposable
    # if the user re-registers the key
    delete @close_listeners[token_key]

    true

  # Dispose of all listeners
  destroy: ->
    for k,v of @file_listeners
      v.dispose()

    for k,v of @close_listeners
      v.dispose()

    true

  # The following looks at all new editors. If the editor is for a basename
  # file, it sets up a callback for a magic token to be written when the editor
  # is closed.
  _create_notif_bn: (token_key) ->
    (editor) =>
      if editor.buffer?.file?.getBaseName() == token_key
        @_setup_listener(editor, token_key)
      true

  # The following looks at all new editors. If the editor is for a basename
  # file, it sets up a callback for a magic token to be written when the editor
  # is closed.
  _create_notif_ext: (token_key) ->
    path = require 'path'
    (editor) =>
      if editor.buffer?.file?.path.split('.').pop() == token_key
        @_setup_listener(editor, token_key)
      true

  # Sets up a listener that will add the magic marker to the end of the file
  # on flie close.
  # The listener for file close is registered so it can be disposed if the
  # user changes their preferences.
  _setup_listener: (editor, token_key) =>
    filepath = editor.buffer.file.getPath()
    disp = editor.onDidDestroy ->
      git_msg_notifier(filepath)

    @close_listeners[token_key] ?= new CompositeDisposable()
    @close_listeners[token_key].add(disp)
    true

# This writes a magic token to the end of a commit message. We expect this to
# be run when the commit message editor has been closed.
git_msg_notifier = (filepath) ->
  fs = require 'fs'
  fs.appendFileSync(filepath, "\n##ATOM EDIT COMPLETE##", {})
  true
