# frozen_string_literal: true

require 'fileutils'
require 'open3'

module DummyAppHelpers
  #
  # Running commands
  #

  def run_command(cmd)
    raise 'No dummy app' if dummy_app.nil?

    stdin, stdout, wait = Open3.popen2('sh', '-c', "bundle exec #{cmd}", chdir: dummy_app)
    yield stdin if block_given?
    code = wait.value
    raise "Exited with code #{code}: #{cmd}" if code != 0

    stdout.read
  ensure
    stdin&.close
    stdout&.close
  end

  def run_ruby
    raise 'No dummy app' if dummy_app.nil?
  end

  #
  # Filesystem
  #

  def dummy_app
    @dummy_app
  end

  def dummy_app_template
    File.expand_path File.join(__dir__, '../dummy')
  end

  def setup_dummy_app
    random_string = SecureRandom.hex.chars.first(4).join
    @dummy_app = File.expand_path File.join(__dir__, "../dummy-#{random_string}")
    FileUtils.cp_r dummy_app_template, @dummy_app
    run_command 'rake db:migrate'
  end

  def teardown_dummy_app
    return if @dummy_app.nil?

    FileUtils.rm_r @dummy_app
    @dummy_app = nil
  end
end
