# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'factory_bot_rails'
require 'rspec/rails'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  FactoryBot.definition_file_paths += Dir['drivers/*/spec/factories']
  FactoryBot.reload
end
