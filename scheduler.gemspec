$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "scheduler/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "rails-scheduler"
  spec.version     = Scheduler::VERSION
  spec.authors     = ["Francesco Ballardin"]
  spec.email       = ["francesco.ballardin@gmail.com"]
  spec.homepage    = "https://github.com/Pluvie/rails-scheduler"
  spec.summary     = "A Rails engine to schedule jobs, handle parallel execution and manage the jobs queue."
  spec.description = "A Rails engine to schedule jobs, handle parallel execution and manage the jobs queue."
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.2"
  
  spec.add_dependency "mongoid",  "~> 7.0.2"
  spec.add_dependency "bson_ext"
  spec.add_dependency "whenever", "~> 0.10.0"

  spec.add_development_dependency "rails-dev-tools"
end
