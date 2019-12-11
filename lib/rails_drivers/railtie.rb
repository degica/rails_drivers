# frozen_string_literal: true

module RailsDrivers
  class Railtie < ::Rails::Railtie
    include ::RailsDrivers::Setup

    config.before_configuration { setup_paths }
    config.after_initialize { RailsDrivers.freeze! }
  end
end
