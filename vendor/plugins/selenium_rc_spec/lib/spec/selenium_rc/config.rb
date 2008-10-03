require 'yaml'
require 'erb'
module Spec::SeleniumRc
  CONFIG_PATH = RAILS_ROOT + '/config/selenium_rc.yml'
  DEFAULT_CONFIG = {
    :app => {
      :host => 'localhost',
      :binding => '127.0.0.1',
      :port => 4545,
      :environment => 'test',
    }.freeze,
    :seleniumrc => {
      :host => 'localhost',
      :port => 4444,
      :browsers => %w[ *firefox ].freeze,
      :timeout => 3000,
    }.freeze
  }.freeze

  CONFIG = Module.new.module_eval do
    if File.exist?(CONFIG_PATH)
      yaml = File.open(CONFIG_PATH) {|f| ERB.new(f.read).result(binding) }
      user_config = YAML.load(yaml).symbolize_keys
      default_app = DEFAULT_CONFIG[:app]
      default_rc = DEFAULT_CONFIG[:seleniumrc]
      {
        :app => default_app.merge(user_config[:app].symbolize_keys),
        :seleniumrc => default_rc.merge(user_config[:seleniumrc].symbolize_keys),
      }
    else
      DEFAULT_CONFIG
    end
  end
end
