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

    it "can be started" do
      expect {
        Scheduler.start
        sleep Scheduler.configuration.polling_interval * 3
        # Directly terminates the scheduler process
        Process.kill :TERM, Scheduler.pid
      }.to_not raise_error
    end

    it "can be stopped" do
      expect {
        Scheduler.start
        sleep Scheduler.configuration.polling_interval * 3
        Scheduler.stop
      }.to_not raise_error
    end

    it "can be restarted" do
      expect {
        Scheduler.start
        sleep Scheduler.configuration.polling_interval * 2
        Scheduler.restart
        sleep Scheduler.configuration.polling_interval * 2
        # Directly terminates the scheduler process
        Process.kill :TERM, Scheduler.pid
      }.to_not raise_error
    end

    context "with a queue of scheduler jobs" do

      before(:each) do
        ExampleSchedulableModel.delete_all
      end

      context "with a number of jobs lesser than the maximum concurrent jobs count" do

        it "immediately queues all jobs" do
          time_to_work = 10
          2.times.map do
            ExampleSchedulableModel.perform_later('ExampleSchedulerJob', time_to_work)
          end

          Scheduler.start
          sleep time_to_work + 1
          Scheduler.stop
          expect(ExampleSchedulableModel.completed.count).to eq 2
        end

      end

      context "with a number of jobs greater than the maximum concurrent jobs count" do

        it "immediately queues the maximum concurrent jobs count" do
          time_to_work = 5
          4.times.map do
            ExampleSchedulableModel.perform_later('ExampleSchedulerJob', time_to_work)
          end

          Scheduler.start
          sleep 2
          # After 2 seconds two jobs are being performed and 2 still queued
          expect(ExampleSchedulableModel.running.count).to eq 2
          expect(ExampleSchedulableModel.queued.count).to eq 2
          # After all working time, all jobs have completed
          sleep time_to_work - 2
          Scheduler.stop
          expect(ExampleSchedulableModel.completed.count).to eq 4
        end

      end

    end

  end

end
