# frozen_string_literal: true

require 'fileutils'
require 'open3'

module DummyAppHelpers
  #
  # Custom matchers
  #

  def self.included(_class)
    RSpec::Matchers.define :have_file do |file_path|
      match do |dummy_app_path|
        File.exist? File.expand_path(File.join(dummy_app_path, file_path))
      end
    end
  end

  #
  # Running commands
  #

  def run_command(cmd)
    raise 'No dummy app' if dummy_app.nil?

    stdin, stdout, wait = Open3.popen2e('sh', '-c', "bundle exec #{cmd}", chdir: dummy_app)
    yield stdin if block_given?
    code = wait.value
    raise "Exited with code #{code}: #{cmd}\n#{stdout.read}" if code != 0

    stdout.read
  ensure
    stdin&.close
    stdout&.close
  end

  def run_ruby(code)
    run_command("rails runner \"#{code.gsub('"', '\\\"')}\"")
  end

  def create_file(file_name, contents)
    full_path = File.expand_path(File.join(dummy_app, file_name))

    dir = full_path.split('/')
    dir.pop
    FileUtils.mkdir_p(dir.join('/'))

    File.open(full_path, 'w') { |f| f.write contents }
  end

  def read_file(file_name)
    IO.read(File.join(dummy_app, file_name))
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
