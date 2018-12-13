describe Scheduler do

  context "its configuration" do

    it "has a :logger parameter" do
      configuration = Scheduler::Configuration.new
      expect(configuration.respond_to? "logger").to be true
      expect(configuration.respond_to? "logger=").to be true
    end

    it "has a :job_class parameter" do
      configuration = Scheduler::Configuration.new
      expect(configuration.respond_to? "job_class").to be true
      expect(configuration.respond_to? "job_class=").to be true
    end

    it "has a :polling_interval parameter" do
      configuration = Scheduler::Configuration.new
      expect(configuration.respond_to? "polling_interval").to be true
      expect(configuration.respond_to? "polling_interval=").to be true
    end

    it "has a :max_concurrent_jobs parameter" do
      configuration = Scheduler::Configuration.new
      expect(configuration.respond_to? "max_concurrent_jobs").to be true
      expect(configuration.respond_to? "max_concurrent_jobs=").to be true
    end

  end

  context "its main process" do

    Scheduler.configure do |config|
      config.polling_interval = 1
      config.max_concurrent_jobs = 2
    end

    # it "can be started" do
    #   expect {
    #     Scheduler.start
    #     sleep Scheduler.configuration.polling_interval * 3
    #     # Directly terminates the scheduler process
    #     Process.kill :TERM, Scheduler.pid
    #   }.to_not raise_error
    # end

    # it "can be stopped" do
    #   expect {
    #     Scheduler.start
    #     sleep Scheduler.configuration.polling_interval * 3
    #     Scheduler.stop
    #   }.to_not raise_error
    # end

    # it "can be restarted" do
    #   expect {
    #     Scheduler.start
    #     sleep Scheduler.configuration.polling_interval * 2
    #     Scheduler.restart
    #     sleep Scheduler.configuration.polling_interval * 2
    #     # Directly terminates the scheduler process
    #     Process.kill :TERM, Scheduler.pid
    #   }.to_not raise_error
    # end

    context "with a queue of scheduler jobs" do

      context "with a number of jobs lesser than the maximum concurrent jobs count" do

        it "immediately queues all jobs" do
          jobs = 2.times.map do
            ExampleSchedulableModel.perform_later('ExampleSchedulerJob', 10)
          end

          Scheduler.start
          sleep 15
          Scheduler.stop
          expect(jobs.pluck(:status)).to all eq :completed
        end

      end

      context "with a number of jobs greater than the maximum concurrent jobs count" do

        it "immediately queues the maximum concurrent jobs count" do
        end

      end

    end

  end

end
