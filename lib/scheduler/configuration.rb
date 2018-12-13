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

    def initialize
      @logger = Rails.logger
      @job_class = ExampleJob
      @polling_interval = 5
      @max_concurrent_jobs = [ Etc.nprocessors, 24 ].min
    end

  end
end
