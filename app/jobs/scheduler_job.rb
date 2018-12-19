class SchedulerJob < ActiveJob::Base
  
  queue_as :default

  ##
  # Performs job with ActiveJob framework.
  #
  # @param [String] job_class the class of the corresponding Job.
  # @param [String] job_id the id of the corresponding Job.
  # @param [Array] *args additional arguments.
  # @param [Proc] &block extra block to define custom jobs.
  #
  # @return [nil]
  def perform(job_class, job_id, *args, &block)
    begin
      @job = job_class.constantize.find(job_id)
      @job.executed_at = Time.current
      @job.status!(:running)
      yield @job, *args if block_given?
      @job.completed_at = Time.current
      @job.progress!(100)
      @job.status!(:completed)
    rescue StandardError => error
      handle_error(error, job_class, job_id)
    end
  end

  ##
  # Method to handle any error raised when performing a job.
  #
  # @param [StandardError] error the raised error.
  # @param [String] job_class the class of the corresponding Job.
  # @param [String] job_id the id of the corresponding Job.
  # @param [Proc] &block extra block to define custom error handling.
  #
  # @return [nil]
  def handle_error(error, job_class, job_id, &block)
    if @job.present?
      @job.completed_at = Time.current
      backtrace = error.backtrace.select { |line| line.include?('app') }.join("\n")
      if block_given?
        yield @job, error, backtrace
      else
        @job.log(:error, "#{error.class}: #{error.message}")
        @job.log(:error, backtrace)
        @job.backtrace = backtrace
        @job.status!(:error)
      end
      @job.save
    else
      raise "Unable to find #{job_class} with id '#{job_id}'."
    end
  end

end
