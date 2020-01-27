# frozen_string_literal: true

module RailsDrivers
  module Overrides
    extend ActiveSupport::Concern

    included do
      possible_overrides = Dir.glob(
        Rails.root.join(
          'drivers', '*', 'overrides',
          "#{name.underscore}_override.rb"
        )
      )

      possible_overrides.each do |path|
        require_dependency path

        include "#{name}Override".constantize
      end
    end
  end
end
