# frozen_string_literal: true

module RailsDrivers
  module Extensions
    extend ActiveSupport::Concern

    # Including this module results in all available extension modules being
    # included.
    included do
      cattr_reader :driver_extensions

      possible_extensions = Dir.glob(
        Rails.root.join(
          'drivers', '*', 'extensions',
          "#{name.underscore}_extension.rb"
        )
      )

      @@driver_extensions = possible_extensions.map do |path|
        load path

        %r{drivers/(?<driver_name>[^/]+)/extensions} =~ path

        extension = "#{driver_name.classify}::#{name}Extension".constantize
        include extension
        extension
      end.freeze

      singleton_class.prepend CheckForShadowedMethods
    end

    # This module is prepended to the singleton class of the including class
    # to detect when an extension is attempting to re-define any methods.
    module CheckForShadowedMethods
      def method_added(method_name)
        driver_extensions.each do |extension|
          next unless extension.instance_methods.include?(method_name)

          Rails.logger.warn "Driver extension method #{extension.name}##{method_name} "\
            "is shadowed by #{name}##{method_name} and will likely not do anything."
        end

        super(method_name)
      end
    end
  end
end
