##
# This spec is for every class that includes the Scheduler::Schedulable module.

RSpec.shared_examples "a schedulable resource" do

  it "is valid if :class_name is present" do
    resource = resource_class.new
    resource.save
    expect(resource).to have(1).error_on(:class_name)
  end

  it "has fields: :class_name, :args, :scheduled_at, :executed_at, :completed_at, :pid, :status, :logs, :progress, :error, :backtrace" do
    resource = resource_class.new
    expect(resource).to have_fields(*resource_attributes.keys)
    expect(resource).to be_able_to_save_fields(resource_attributes)
  end

  it "can be scheduled to execute" do
    resource = resource_class.new resource_attributes
    expect(resource.respond_to? :schedule).to be true
  end

  it "can be progressed to a given amount" do
    resource = resource_class.create resource_attributes
    progress = rand(51.0..90.0)
    resource.progress! progress
    expect(resource.reload.progress).to eq progress
  end

  it "can be progressed by a given amount" do
    resource = resource_class.create resource_attributes
    progress = rand(1.0..10.0)
    previous_progress = resource.progress
    resource.progress_by! progress
    expect(resource.reload.progress).to eq (previous_progress + progress)
  end
  
  context "when it is scheduled to execute" do
    
    it "becomes with status :queued" do
      resource = resource_class.new resource_attributes
      resource.schedule
      expect(resource.status).to eq :queued
    end

    it "sets field :scheduled_at with current time" do
      resource = resource_class.new resource_attributes
      resource.schedule
      expect(resource.scheduled_at.present?).to be true
    end
    
    it "resets fields :logs, :progress, :error, :backtrace, :completed_at, :executed_at" do
      resource = resource_class.new resource_attributes
      resource.schedule
      expect(resource.logs).to be_empty
      expect(resource.progress).to eq 0.0
      expect(resource.error.nil?).to be true
      expect(resource.backtrace.nil?).to be true
      expect(resource.completed_at.nil?).to be true
      expect(resource.executed_at.nil?).to be true
    end

  end

  context "when it is set to perform later" do

    it "creates an instance of the resource class" do
      resource = resource_class.new resource_attributes
      resource.perform_later
      expect(resource_class.find(resource.id)).to_not be nil
    end

    it "queues a SchedulerJob in ActiveJob queue" do
      expect {
        resource = resource_class.new resource_attributes
        resource.perform_later
      }.to have_enqueued_job(SchedulerJob).with do |job_class, job_id, *args|
        expect(job_class).to eq resource_class
        expect(job_id).to eq resource.id.to_s
      end
    end

  end

  context "when it is performed" do

    it "performs a SchedulerJob with specified args" do
      resource = resource_class.new resource_attributes
      job = resource.perform_now
      expect(job.reload.status).to eq :completed
    end

  end

end