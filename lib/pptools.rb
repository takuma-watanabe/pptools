require "pptools/version"
require "Thor"
require "Messages"
require "CodeMaster"
require "Constants"

module Pptools
  class MyCLI < Thor 

    desc "message [SUB COMMAND]", "SUB COMMAND are {client, server, view}."
    subcommand("message", Messages)

    desc "code [SUB COMMAND]", "SUB COMMAND are {client, server, view}."
    subcommand("code", CodeMaster)

    desc "constants [SUB COMMAND]", "SUB COMMAND are {client, server, view}."
    subcommand("constants", Constants)

  end
end
