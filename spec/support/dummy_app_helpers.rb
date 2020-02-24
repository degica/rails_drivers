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

  def wait_for_command(cmd, stdout, stderr, process, capture_stderr = false)
    error = truncate_lines(stderr)
    std = truncate_lines(stdout)
    code = process.value
    raise "Exited with code #{code}: #{cmd}\n#{error.join}\n#{std.join}" if code != 0

    result = []
    result += error if capture_stderr
    result += std
    result.join
  end

  def run_command(cmd, input: nil, capture_stderr: false)
    raise 'No dummy app' if dummy_app.nil?

    stdin, stdout, stderr, process = Open3.popen3('sh', '-c', "bundle exec #{cmd}", chdir: dummy_app)
    stdin.write input if input
    stdin.close

    wait_for_command(cmd, stdout, stderr, process, capture_stderr)
  ensure
    stdout&.close
    stderr&.close
  end

  def run_ruby(code)
    run_command("rails runner \"#{code.gsub('"', '\\\"')}\"")
  end

  #
  # HTTP requests
  #

  def http(method, path)
    run_ruby <<-RUBY
      include Rack::Test::Methods
      def app; Rails.application; end
      #{method} #{path.inspect}
      puts last_response.body
    RUBY
  end

  def find_js_pack(html, pack_name)
    match = %r{<script .+(?<script_file>packs/js/#{pack_name}-.+\.js).+</script>}.match(html)
    expect(match).to_not be_nil, -> { "Couldn't find a script tag for #{pack_name}-*.js in HTML:\n\n#{html}" }
    match[:script_file]
  end

  #
  # Reading and writing files
  #

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
    File.expand_path File.join(__dir__, "../dummy_#{ENV['RAILS_VERSION']}")
  end

  def setup_dummy_app
    random_string = SecureRandom.hex.chars.first(4).join
    @dummy_app = File.expand_path File.join(__dir__, "../dummy-#{random_string}")
    FileUtils.rm_r @dummy_app if File.exist?(@dummy_app)
    FileUtils.cp_r dummy_app_template, @dummy_app
  end

  def teardown_dummy_app
    return if @dummy_app.nil?

    FileUtils.rm_r @dummy_app
    @dummy_app = nil
  end

  #
  # Private
  #

  private

  def truncate_lines(stream, limit: 200)
    lines = []

    stream.each_line do |line|
      lines << line unless lines.size > limit
    end

    lines[-1] = '...' if lines.size > limit

    lines
  end
end
