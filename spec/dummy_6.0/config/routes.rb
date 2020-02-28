# frozen_string_literal: true

require 'rails_drivers/routes'

RailsDrivers::Routes.load_driver_routes

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
end
