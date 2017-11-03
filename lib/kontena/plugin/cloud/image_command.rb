class Kontena::Plugin::Cloud::ImageCommand < Kontena::Command

  subcommand ['list', 'ls'], 'List image repositories', load_subcommand('kontena/plugin/cloud/image/list_command')
  subcommand ['show'], 'Show image repository details', load_subcommand('kontena/plugin/cloud/image/show_command')
  subcommand ['login-docker'], 'Login docker to image registry', load_subcommand('kontena/plugin/cloud/image/login_command')
  subcommand ['tag'], 'Image repository tag specific commands', load_subcommand('kontena/plugin/cloud/image/tag_command')

  def execute
  end
end