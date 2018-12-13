module Scheduler
  class Configuration

    # @return [String] a logger file.
    attr_accessor :logger
    # @return [Class] the class of the main job model.
    attr_accessor :job_class
    # @return [Integer] how much time to wait before each iteration.
    attr_accessor :polling_interval
    # @return [Integer] maximum number of concurent jobs.
    attr_accessor :max_concurrent_jobs
    # @return [Boolean] whether to perform jobs when in test or development env.
    attr_accessor :perform_jobs_in_test_or_development

    def initialize
      @logger = Rails.logger
      @job_class = ExampleSchedulableModel
      @polling_interval = 5
      @max_concurrent_jobs = [ Etc.nprocessors, 24 ].min
      @perform_jobs_in_test_or_development = false
    end

  end
end
