require "scheduler/engine"
require "scheduler/configuration"
require "scheduler/main_process"

module Scheduler

  class << self

    # @return [Scheduler::Configuration] the configuration class for Scheduler.
    attr_accessor :configuration

    ##
    # Initializes configuration.
    #
    # @return [Scheduler::Configuration] the configuration class for Scheduler.
    def configuration
      @configuration || Scheduler::Configuration.new
    end

    ##
    # Method to configure various Scheduler options.
    #
    # @return [nil]
    def configure
      @configuration ||= Scheduler::Configuration.new
      yield @configuration
    end

    ##
    # Gets scheduler pid file.
    #
    # @return [String] the pid file.
    def pid_file
      '/tmp/rails-scheduler.pid'
    end

    ##
    # Gets scheduler main process pid.
    #
    # @return [Integer] main process pid.
    def pid
      File.read(self.pid_file).to_i rescue nil
    end

    ##
    # Starts a Scheduler::MainProcess in a separate process.
    #
    # @return [nil]
    def start
      scheduler_pid = Process.fork do
        begin
          Process.daemon(true)
          File.open(self.pid_file, 'w+') do |pidfile|
            pidfile.puts Process.pid
          end
          scheduler = Scheduler::MainProcess.new
        rescue StandardError => e
          Rails.logger.error "#{e.class}: #{e.message} (#{e.backtrace.first})".red
        end
      end
      Process.detach(scheduler_pid)
      scheduler_pid
    end

    ##
    # Reschedules all running jobs and stops the scheduler main process.
    #
    # @return [nil]
    def stop
      begin  
        Process.kill :TERM, Scheduler.pid
        FileUtils.rm(self.pid_file)
      rescue TypeError, Errno::ENOENT, Errno::ESRCH
      end
    end

    ##
    # Restarts the scheduler.
    #
    # @return [nil]
    def restart
      self.stop
      self.start
    end

  end

end
