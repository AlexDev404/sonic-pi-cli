require 'socket'
require 'rubygems'
require 'osc-ruby'
require 'securerandom'

class SonicPi
  PORT_LOG_REGEX = Regexp.compile(/Listen port:\s+(?<port>\d+)/)
  DAEMON_STDOUT_REGEX = Regexp.compile(/daemon_stdout:\s+(?<value>-?\d+)/)

  def initialize(port=nil, token=nil)
    connection = find_connection
    @port = port || connection[:port]
    @token = token.nil? ? connection[:token] : token
    @connection_source = connection[:source]
  end

  RUN_COMMAND = "/run-code"
  STOP_COMMAND = "/stop-all-jobs"
  SERVER = 'localhost'
  GUI_ID = 'SONIC_PI_CLI'

  def run(command)
    send_command(RUN_COMMAND, command)
  end

  def stop
    send_command(STOP_COMMAND)
  end

  def test_connection!
    return if @connection_source == :gui_log

    begin
      socket = UDPSocket.new
      socket.bind(nil, @port)
      abort("ERROR: Sonic Pi is not listening on #{@port} - is it running?")
    rescue
      # everything is good
    end
  end

  private

  def client
    @client ||= OSC::Client.new(SERVER, @port)
  end

  def send_command(call_type, command=nil)
    args =
      if @token
        [@token]
      else
        [GUI_ID]
      end

    args << command unless command.nil?

    prepared_command = OSC::Message.new(call_type, *args)
    client.send(prepared_command)
  end

  def find_connection
    connection = find_gui_log_connection
    return connection if connection

    legacy_port = find_legacy_port
    { port: legacy_port, token: nil, source: :legacy_log }
  end

  def find_gui_log_connection
    values = []

    File.open(File.join(log_path, "gui.log"), 'r') do |file|
      file.each_line do |line|
        value = line[DAEMON_STDOUT_REGEX, "value"]
        values << value.to_i if value
      end
    end

    return unless values.length >= 6

    {
      port: values[-4],
      token: values[-1],
      source: :gui_log,
    }
  rescue Errno::ENOENT
    nil
  end

  def find_legacy_port
    port = 4557

    begin
      File.open(File.join(log_path, "server-output.log"), 'r') do |f|
        port_log_entry =
          f.each_line
          .lazy
          .map { |line| line[PORT_LOG_REGEX, "port"] }
          .find { |match| !!match }

        port = port_log_entry.to_i if port_log_entry
      end
    rescue Errno::ENOENT
      # not to worry if the file doesn't exist
    end

    port
  end

  def log_path
    base_path = ENV["SONIC_PI_HOME"] || File.join(Dir.home, ".sonic-pi")
    File.join(base_path, "log")
  end
end
