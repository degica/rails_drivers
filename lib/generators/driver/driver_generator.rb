# frozen_string_literal: true

class DriverGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_driver_dir_structure
    create_file "#{RailsDrivers.config.drivers_path}/#{file_name}/app/models/#{file_name}/.keep", ''
    create_file "#{RailsDrivers.config.drivers_path}/#{file_name}/app/controllers/#{file_name}/.keep", ''
    create_file "#{RailsDrivers.config.drivers_path}/#{file_name}/app/views/#{file_name}/.keep", ''
    create_file "#{RailsDrivers.config.drivers_path}/#{file_name}/spec/.keep", ''
    create_file "#{RailsDrivers.config.drivers_path}/#{file_name}/db/migrate/.keep", ''
    create_file "#{RailsDrivers.config.drivers_path}/#{file_name}/lib/tasks/.keep", ''
    create_file "#{RailsDrivers.config.drivers_path}/#{file_name}/extensions/.keep", ''

    create_templated_files
  end

  def create_templated_files
    template 'routes.rb.erb',      "#{RailsDrivers.config.drivers_path}/#{file_name}/config/routes.rb"
    template 'initializer.rb.erb', "#{RailsDrivers.config.drivers_path}/#{file_name}/config/initializers/#{file_name}_feature.rb"
    template 'module.rb.erb',      "#{RailsDrivers.config.drivers_path}/#{file_name}/app/models/#{file_name}.rb"
    template 'README.md.erb',      "#{RailsDrivers.config.drivers_path}/#{file_name}/README.md"
  end
end
