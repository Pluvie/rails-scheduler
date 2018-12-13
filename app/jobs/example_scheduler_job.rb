class ExampleSchedulerJob < SchedulerJob
  
  ##
  # Performs job with ActiveJob framework.
  #
  # @param [String] job_id the id of the corresponding Job.
  # @param [Integer] work_time an example amount of time to simulate work.
  #
  # @return [nil]
  def perform(job_class, job_id, *args, &block)
    super do |job, work_time|
      job.log :info, "Preparing to do some work for #{work_time} seconds."
      sleep work_time
      job.log :info, "Work done!"
    end
  end

end
