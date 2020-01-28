# frozen_string_literal: true

module RailsDrivers
  module Overrides
    extend ActiveSupport::Concern

    # Including this module results in all available override modules being
    # included.
    included do
      cattr_reader :driver_overrides

      possible_overrides = Dir.glob(
        Rails.root.join(
          'drivers', '*', 'overrides',
          "#{name.underscore}_override.rb"
        )
      )

      @@driver_overrides = possible_overrides.map do |path|
        require_dependency path
        %r{drivers/(?<driver_name>[^/]+)/overrides} =~ path

        override = "#{driver_name.classify}::#{name}Override".constantize
        include override
        override
      end.freeze

      singleton_class.prepend CheckForShadowedMethods
    end

    # This module is prepended to the singleton class of the including class
    # to detect when an override is attempting to re-define any methods.
    module CheckForShadowedMethods
      def method_added(method_name)
        driver_overrides.each do |override|
          next unless override.instance_methods.include?(method_name)

          Rails.logger.warn "Driver override method #{override.name}##{method_name} "\
            "is shadowed by #{name}##{method_name} and will likely not do anything."
        end

        super(method_name)
      end
    end
  end
end
