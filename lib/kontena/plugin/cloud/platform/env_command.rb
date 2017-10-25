require_relative 'common'

class Kontena::Plugin::Cloud::Platform::EnvCommand < Kontena::Command
  include Kontena::Cli::Common

  def execute
    Kontena.run!(['grid','env'])
  end
end