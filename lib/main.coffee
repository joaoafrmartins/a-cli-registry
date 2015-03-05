merge = require 'lodash.merge'

{ resolve } = require 'path'

{ existsSync } = require 'fs'

Mixto = require 'mixto'

ACliUsage = require 'a-cli-usage'

class ACliRegistry extends Mixto

  @options: commandName: "!"

  @commands: {}

  @usage: ACliUsage.usage

  @filename: 'package.json'

  @home: (main) ->

    if not main then throw new Error "invalid package main #{main}"

    file = main

    while not existsSync resolve file, @filename

      file = resolve file, '..'

      if not file.match resolve process.env.HOME

        throw new Error "could not resolve #{@filename} location"

    return file

  @register: (command, defaults) ->

    ACliUsage.options = @options

    _command = {}

    {

      commandMain: _command.main,

      commandName: _command.name,

      commandVersion: _command.version,

      commandDescription: _command.description,

      commandSynopsys: _command.synopsys,

      commandUsage: _command.usage,

      commandOptions: _command.options

      commandTriggers: _command.triggers

    } = command.options

    if _command.main and not defaults

      defaults = @package _command.main

    defaults ?= {}

    Object.keys(_command).forEach (k) -> _command[k] ?= defaults[k]

    @commands[_command.name] ?= {}

    @commands[_command.name] = merge @commands[_command.name], _command

    ACliUsage.register @commands[_command.name]

  @package: (main) ->

    return require resolve @home(main), @filename

  @help: (command=@options.commandName) ->

    return _command =

      name: command,

      options:[
        {
          name: "help",
          value: command,
          type: "string"
          command: @options.commandName
        }
      ]

      args: help: command

module.exports = ACliRegistry
