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
    stdin.close

    lines = truncate_lines(stdout)
    code = wait.value
    raise "Exited with code #{code}: #{cmd}\n#{lines.join}" if code != 0

    lines.join
  ensure
    stdout&.close
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
    match = %r{<script .+(?<script_file>packs/#{pack_name}-.+\.js).+</script>}.match(html)
    expect(match).to_not be_nil, -> { "Couldn't find a script tag for #{pack_name}-*.js in HTML:\n\n#{html}" }
    match[:script_file]
  end

  #
  # Reading and writing files
  #

  def create_file(file_name, contents)
    full_path = File.expand_path(File.join(dummy_app, file_name))

    FileUtils.mkdir_p(File.dirname(full_path))

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

  def dummy_app_workdir
    "#{@dummy_app}.workdir"
  end

  def dummy_app_upper
    "#{@dummy_app}.upper"
  end

  def all_dummy_app_dirs
    [dummy_app, dummy_app_workdir, dummy_app_upper]
  end

  def dummy_app_template
    File.expand_path File.join(__dir__, '../dummy')
  end

  def setup_dummy_app
    random_string = SecureRandom.hex.chars.first(4).join
    @dummy_app = File.expand_path File.join(__dir__, "../dummy-#{random_string}")

    all_dummy_app_dirs.each do |dir|
      FileUtils.rm_rf dir
      FileUtils.mkdir dir
    end

    try_overlayfs or copy_dummy_app
  end

  def teardown_dummy_app
    return if @dummy_app.nil?

    until system "fusermount -u #{@dummy_app}"
      sleep 1
    end if @using_fuse
    all_dummy_app_dirs.each do |dir|
      FileUtils.rm_r dir
    end

    @dummy_app = nil
    @using_fuse = nil
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

  def try_overlayfs
    return false if ENV['NO_OVERLAYFS']
    low  = dummy_app_template
    up   = dummy_app_upper
    work = dummy_app_workdir

    cmd = "fuse-overlayfs -o 'lowerdir=#{low},upperdir=#{up},workdir=#{work}' #{dummy_app}"
    @using_fuse = system cmd
  end

  def copy_dummy_app
    FileUtils.rmdir dummy_app
    FileUtils.cp_r dummy_app_template, dummy_app
  end
end
