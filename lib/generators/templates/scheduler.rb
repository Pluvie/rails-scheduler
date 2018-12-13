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
  # Defaults to ExampleSchedulableModel, which is a bare class that
  # just includes Scheduler::Schedulable module.
  #
  # config.job_class = ExampleSchedulableModel

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

  ##
  # Sets whether to perform jobs when in test or development env.
  # Usually jobs are performed only when a Scheduler::MainProcess is running.
  # But for convenience, you can set this parameter to true so you
  # don't need to keep a Scheduler::MainProcess running.
  # Defaults to false.
  #
  # config.perform_jobs_in_test_or_development = false

end
