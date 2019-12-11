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
  spec.description = 'Like Rails Engines, but without the friction. '\
                     "Your Rails app can't access them, and they can't access each other."
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.pkg.github.com/degica/rails_drivers'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '~> 5.2.3'

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'sqlite3'
end
