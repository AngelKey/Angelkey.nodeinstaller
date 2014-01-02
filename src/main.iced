{getopt} = require './getopt'
{fullname,bin,version} = require './package'
{make_esc} = require 'iced-error'
{BaseCommand} = require './base'
{Installer} = require './installer'
gpg = require 'gpg-wrapper'

##========================================================================

class VersionCommand extends BaseCommand

  run : (cb) ->
    console.log fullname()
    cb null

##========================================================================

class HelpCommand extends BaseCommand

  constructor : (@argv, @err = null) ->

  run : (cb) ->
    console.log """usage: #{bin()} [<keybase-version>]

\tUpgrade or install a version of keybase.  Check signatures for Keybase.io's signing
\tkey. You can provide a specific version or by default you'll get the most recent
\tversion.

\tVersion: #{version()}

"""

    cb @err

##========================================================================

class Main

  @OPTS :
    a :
      alias : 'about'
      action : "storeTrue"
      help : 'display version and command name, then quit'

  #-----------

  constructor : ->
    @cmd = null

  #-----------

  parse_args : (cb) ->
    err = null
    @argv = getopt process.argv[2...], { flags : [ "h", "v", "help", "version", "?" ] }
    if @argv.get("v", "version")
      @cmd = new VersionCommand()
    else if @argv.get("h", "?", "help")
      @cmd = new HelpCommand()
    else if @argv.get().length > 1
      @cmd = new HelpCommand @argv, (new Error "Usage error: only zero or one argument allowed")
    else
      @cmd = new Installer @argv
    cb err

  #-----------

  run : (cb) ->
    esc = make_esc cb, "run"
    await @setup    esc defer()
    await @cmd.run  esc defer()
    cb null

  #-----------

  main : () ->
    await @run defer err
    if err? then console.warn err.message
    process.exit if err? then -2 else 0

  #-----------

  setup : (cb) ->
    esc = make_esc cb, "setup"
    await @parse_args esc defer()
    cb null

##========================================================================

exports.run = run = () -> (new Main).main()

##========================================================================