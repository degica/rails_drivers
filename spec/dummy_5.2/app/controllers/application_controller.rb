# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from StandardError do |error|
    # This is much nicer for spec failures
    render status: 500,
           inline: "#{error.class} #{error.message}\n\n#{error.backtrace}"
  end
end
