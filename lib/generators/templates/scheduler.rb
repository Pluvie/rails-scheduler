##
# Example configuration file for rails-scheduler gem.
Scheduler.configure do |config|

  ##
  # A logger interface to save scheduler logs.
  # Defaults to Rails.logger.
  #
  # config.logger = Rails.logger

  ##
  # A custom class to handle the execution of jobs.
  # This class must include Scheduler::Schedulable module
  # in order to work.
  # Defaults to ExampleJob, which is a bare class that
  # just includes Scheduler::Schedulable module.
  #
  # config.job_class = ExampleJob

  ##
  # How often the scheduler has to check for new jobs to run.
  # Defaults to 5 seconds.
  #
  # config.polling_interval = 5
  
  ##
  # How many jobs can run at a given time.
  # Defaults to the minimum value between the number of the current
  # machine CPU cores or 24.
  #
  # config.max_concurrent_jobs = [ Etc.nprocessors, 24 ].min

end
