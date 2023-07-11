# frozen_string_literal: true

module RailsDrivers
  module Extensions
    extend ActiveSupport::Concern

    # Including this module results in all available extension modules being
    # included.
    included do
      possible_extensions = Dir.glob(
        Rails.root.join(
          'drivers', '*', 'extensions',
          "#{name.underscore}_extension.rb"
        )
      )

      # Every extension should be a module. Require all extensions.
      included_extensions = possible_extensions.map do |path|
        require_dependency path

        %r{drivers/(?<driver_name>[^/]+)/extensions} =~ path

        extension = "#{driver_name.classify}::#{name}Extension".constantize
        include extension
        extension
      end.freeze

      # Show a warning when an extension tries to overload a core method.
      singleton_class.prepend(Module.new do
        define_method :method_added do |method_name|
          included_extensions.each do |extension|
            next unless extension.instance_methods.include?(method_name)

            Rails.logger.warn "Driver extension method #{extension.name}##{method_name} " \
                              "is shadowed by #{name}##{method_name} and will likely " \
                              'not do anything.'
          end

          super(method_name)
        end
      end)
    end
  end
end
