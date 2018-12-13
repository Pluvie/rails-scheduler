describe ExampleSchedulableModel do

  it_behaves_like "a schedulable resource" do
    let(:resource_class) { ExampleSchedulableModel }
    let(:resource_attributes) do
      { class_name: 'SchedulerJob',
        args: [ 'No args.' ],
        scheduled_at: Time.current,
        executed_at: Time.current,
        completed_at: Time.current,
        pid: Process.pid,
        status: ExampleSchedulableModel.statuses.sample,
        logs: [ [ :info, 'Job started.' ] ],
        progress: rand(0.1..50.0),
        error: 'No error.',
        backtrace: 'No backtrace.' }
    end
  end

end
