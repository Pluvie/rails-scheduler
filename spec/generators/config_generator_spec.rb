require 'generators/scheduler/config_generator'

# Includes Thor actions to handle files
require 'thor'
include Thor::Base
include Thor::Actions

RSpec.describe Scheduler::Generators::ConfigGenerator do

  it "generates a configuration file for the scheduler" do

    remove_file 'test/dummy/config/initializers/scheduler.rb'
    Scheduler::Generators::ConfigGenerator.start([], destination_root: 'test/dummy')
    expect(File).to exist('test/dummy/config/initializers/scheduler.rb')
    
  end

end
