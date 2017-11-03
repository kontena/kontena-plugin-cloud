class Kontena::Plugin::Cloud::Image::TagCommand < Kontena::Command

    subcommand ['list', 'ls'], 'List image repository tags', load_subcommand('kontena/plugin/cloud/image/tag/list_command')
    subcommand ['remove', 'rm'], 'Remove tags from image repositor', load_subcommand('kontena/plugin/cloud/image/tag/remove_command')

    def execute
    end
  end