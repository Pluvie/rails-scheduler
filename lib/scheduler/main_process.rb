module Scheduler
  class MainProcess

    # @return [Integer] pid of the main process.
    attr_accessor :pid
    # @return [String] a logger file.
    attr_accessor :logger
    # @return [Class] the class of the main job model.
    attr_accessor :job_class
    # @return [Integer] how much time to wait before each iteration.
    attr_accessor :polling_interval
    # @return [Integer] maximum number of concurent jobs.
    attr_accessor :max_concurrent_jobs

    ##
    # Creates a MainProcess which keeps running
    # and continuously checks if new jobs are queued.
    #
    # @return [Scheduler::MainProcess] the created MainProcess.
    def initialize
      @pid = Process.pid
      @logger = Scheduler.configuration.logger
      @job_class = Scheduler.configuration.job_class
      @polling_interval = Scheduler.configuration.polling_interval
      @max_concurrent_jobs = Scheduler.configuration.max_concurrent_jobs

      unless @logger.instance_of?(ActiveSupport::Logger) or @logger.instance_of?(Logger)
        @logger = Logger.new(@logger)
      end

      if @polling_interval < 1
        @logger.warn "[Scheduler:#{@pid}] Warning: specified a polling interval lesser than 1: "\
          "it will be forced to 1.".yellow
        @polling_interval = 1
      end
      
      unless @job_class.included_modules.include? Scheduler::Schedulable
        raise "The given job class '#{@job_class}' is not a Schedulable class. "\
          "Make sure to add 'include Scheduler::Schedulable' to your class."
      end
      
      self.background
    end
  
    ##
    # Main loop.
    #
    # @return [nil]
    def background
      loop do
        begin
          # Loads up a job queue.
          queue = []
          
          # Counts jobs to schedule.
          running_jobs = @job_class.running.entries
          schedulable_jobs = @job_class.queued.order_by(scheduled_at: :asc).entries
          jobs_to_schedule = @max_concurrent_jobs - running_jobs.count
          jobs_to_schedule = 0 if jobs_to_schedule < 0
  
          # Finds out scheduled jobs waiting to be performed.
          scheduled_jobs = []
          schedulable_jobs.first(jobs_to_schedule).each do |job|
            job_pid = Process.fork do
              begin
                job.perform_now
              rescue StandardError => e
                @logger.error "[Scheduler:#{@pid}] Error #{e.class}: #{e.message} "\
                  "(#{e.backtrace.select { |l| l.include?('app') }.first}).".red
              end
            end
            Process.detach(job_pid)
            job.update_attribute(:pid, job_pid)
            scheduled_jobs << job
            queue << job.id.to_s
          end
  
          # Logs launched jobs
          if scheduled_jobs.any?
            @logger.info "[Scheduler:#{@pid}] Launched #{scheduled_jobs.count} "\
              "jobs: #{scheduled_jobs.map(&:id).map(&:to_s).join(', ')}.".cyan
          else
            @logger.warn "[Scheduler:#{@pid}] No jobs launched, reached maximum "\
              "number of concurrent jobs. Jobs in queue: #{queue.inspect}.".yellow
          end
  
          # Checks for completed jobs: clears up queue and kills any zombie pid
          queue.delete_if do |job_id|
            job = @job_class.find(job_id)
            if job.present? and job.status.in? [ :completed, :error ]
              begin
                @logger.info "[Scheduler:#{@pid}] Rimosso processo #{job.pid} per lavoro completato".cyan
                Process.kill :QUIT, job.pid
              rescue Errno::ENOENT, Errno::ESRCH
              end
              true
            else false end
          end
  
          # Waits the specified amount of time before next iteration
          sleep @loop_interval
        rescue StandardError => error
          @logger.error "[Scheduler:#{@pid}] Error #{error.message}".red
          @logger.error error.backtrace.select { |line| line.include?('app') }.join("\n").red
        rescue Interrupt
          @logger.warn "[Scheduler:#{@pid}] Received interrupt, terminating scheduler..".yellow
          break
        end
      end
    end

  end
end
