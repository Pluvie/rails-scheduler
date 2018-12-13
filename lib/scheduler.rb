require "scheduler/engine"
require "scheduler/configuration"
require "scheduler/main_process"

module Scheduler

  class << self

    # @return [Scheduler::Configuration] the configuration class for Scheduler.
    attr_accessor :configuration

    ##
    # Method to configure various Scheduler options.
    #
    # @return [Scheduler::Configuration] the configuration class for Scheduler.
    def self.configure
      self.configuration ||= Scheduler::Configuration.new
      yield configuration
    end

    ##
    # Starts a Scheduler::MainProcess in a separate process.
    #
    # @return [nil]
    def start
      scheduler_pid = Process.fork do
        begin
          Process.daemon(true)
          File.open('/tmp/rails-scheduler.pid', 'w+') do |pidfile|
            pidfile.puts Process.pid
          end
          scheduler = Scheduler.new
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
      Job.running.each do |job|
        begin
          Process.kill :QUIT, job.pid if job.pid.present?
        rescue Errno::ESRCH, Errno::EPERM
        ensure
          job.status!(:queued)
        end
      end

      begin  
        Process.kill :QUIT, File.read('/tmp/rails-scheduler.pid').to_i
        FileUtils.rm('/tmp/rails-scheduler.pid')
      rescue Errno::ENOENT, Errno::ESRCH
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
