# frozen_string_literal: true

module RailsDrivers
  module Overrides
    extend ActiveSupport::Concern

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

        override = "#{name}Override".constantize
        include override
        override
      end.freeze
    end
  end
end
