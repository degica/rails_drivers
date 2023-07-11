# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'rails_drivers/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'rails_drivers'
  spec.version     = RailsDrivers::VERSION
  spec.authors     = ['Nigel Baillie']
  spec.email       = ['nbaillie@degica.com']
  spec.homepage    = 'https://github.com/degica/rails_drivers'
  spec.summary     = 'De-coupled separation of concerns for Rails'
  spec.description = 'Like Rails Engines, but without the friction. ' \
                     "Your Rails app can't access them, and they can't access each other."
  spec.license     = 'MIT'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  spec.executables << 'driver'
  spec.executables << 'nodriver'

  spec.required_ruby_version = '>= 2.5' # rubocop:disable Gemspec/RequiredRubyVersion

  rails = case ENV.fetch('RAILS_VERSION', nil)
          when '5.2'
            '~> 5.2'
          when '6.0'
            '~> 6.0'
          else
            '>= 5.2'
          end

  spec.add_dependency 'rails', rails

  spec.metadata['rubygems_mfa_required'] = 'true'
end
