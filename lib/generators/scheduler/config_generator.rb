require 'rails/generators'

module Scheduler
  module Generators
    
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a scheduler configuration file."

      def copy_config
        template "scheduler.rb", "config/initializers/scheduler.rb"
      end

    end

  end
end