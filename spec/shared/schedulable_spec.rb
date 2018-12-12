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

end