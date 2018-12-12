describe Scheduler::Job do

  it_behaves_like "a schedulable resource" do
    let(:resource_class) { Job }
    let(:resource_attributes) do
      { class_name: 'MainJob',
        args: [ 'No args.' ],
        scheduled_at: Time.current,
        executed_at: Time.current,
        completed_at: Time.current,
        pid: rand(1..7777),
        status: Job.statuses.sample,
        logs: [ [ :info, 'Job started.' ] ],
        progress: rand(0.1..100.0),
        error: 'No error.',
        backtrace: 'No backtrace.' }
    end
  end

end
