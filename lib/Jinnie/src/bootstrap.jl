push!(LOAD_PATH, abspath("./"))
push!(LOAD_PATH, abspath("config"))
push!(LOAD_PATH, abspath("lib/"))
push!(LOAD_PATH, abspath("lib/Jinnie/src"))

using Mux
using Mustache
using ArgParse

using Util
using Database
using Migrations

function load_configurations()
  include(abspath("config/loggers.jl"))
  include(abspath("config/secrets.jl"))
  include(abspath("config/renderers.jl"))
  include(abspath("config/routes.jl"))
end

function load_dependencies()
  include(abspath("lib/Jinnie/src/fs_watcher.jl"))
  include(abspath("lib/Jinnie/src/command_args_parser.jl"))
  include(abspath("lib/Jinnie/src/middlewares.jl"))
  include(abspath("lib/Jinnie/src/renderer.jl"))
  include(abspath("lib/Jinnie/src/jinnie.jl"))
  include(abspath("lib/Jinnie/src/tasks.jl"))
  include(abspath("lib/Jinnie/src/filetemplates.jl"))
end

function setup_defaults(parsed_args)
  app_env = parsed_args["env"] != nothing ? parsed_args["env"] : Jinnie.config.app_env
  server_port = parsed_args["server-port"] != nothing ? parsed_args["server-port"] : Jinnie.config.server_port
end

function startup(parsed_args = Dict, start_server = false)
  if ( isempty(parsed_args) ) parsed_args = parse_commandline_args() end
  setup_defaults(parsed_args)

  if parsed_args["s"] == "s" || start_server == true 
    if parsed_args["monitor"] == "true" 
      Jinnie.start_server(config.server_port)
      monitor_changes() 
    else
      @sync Jinnie.start_server(config.server_port) 
    end
  end
end

load_configurations()
load_dependencies()
config.auto_connect && db_connect()
include_libs()
include_initializers()
include_resources()