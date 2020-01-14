# frozen_string_literal: true

class DriverGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_driver_dir_structure
    create_file "drivers/#{file_name}/app/models/#{file_name}/.keep", ''
    create_file "drivers/#{file_name}/app/controllers/#{file_name}/.keep", ''
    create_file "drivers/#{file_name}/app/views/#{file_name}/.keep", ''
    create_file "drivers/#{file_name}/spec/.keep", ''
    create_file "drivers/#{file_name}/db/migrate/.keep", ''
    create_file "drivers/#{file_name}/lib/tasks/.keep", ''

    template 'routes.rb.erb',      "drivers/#{file_name}/config/routes.rb"
    template 'initializer.rb.erb', "drivers/#{file_name}/config/initializers/#{file_name}_feature.rb"
    template 'module.rb.erb',      "drivers/#{file_name}/app/models/#{file_name}.rb"
  end
end
