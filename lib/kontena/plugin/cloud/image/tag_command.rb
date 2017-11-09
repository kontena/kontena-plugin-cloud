class Kontena::Plugin::Cloud::Image::TagCommand < Kontena::Command

    subcommand ['list', 'ls'], 'List image repository tags', load_subcommand('kontena/plugin/cloud/image/tag/list_command')

    def execute
    end
  end