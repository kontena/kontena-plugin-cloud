module Kontena::Plugin::Cloud::Node::PlatformOption

  def self.included(base)
    if base.respond_to?(:option)
      base.option '--platform', 'PLATFORM', 'Specify Kontena Cloud platform to use' do |platform|
        config.current_master = platform
        config.current_grid = platform.split('/')[1]
      end
    end
  end
end