# Scheduler
This gem aims to create a simple yet efficient framework to handle job scheduling and execution. Currently it supports only MongoDB as database.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'scheduler'
```

And then execute:
```bash
$ bundle install
```

And then install the config file with:
```bash
$ rails generate scheduler:config
```

## Usage
This gem adds a `Scheduler` module which can be started, stopped or restarted with their corresponding rake task:
```bash
$ rails scheduler:start
$ rails scheduler:stop
$ rails scheduler:restart
```
A `Scheduler` is a process that keeps running looking for jobs to perform. The jobs are documents of a specific collection that you can specify in the scheduler configuration file. You can specify your own model to act as a schedulable entity, as long as it includes the `Schedulable` module. The other configuration options are explained in the generated `config/initializers/scheduler.rb` file.

This gem also gives you a base ActiveJob implementation, called `SchedulerJob`, which you can subclass in order to implement your jobs.

As an example, the gem comes with a `ExampleSchedulableModel` which is a bare class that just includes the `Schedulable` module, and also an `ExampleSchedulerJob` job which is a bare implementation of the `SchedulableJob` job that just sleeps for a given amount of time.

First start by running the scheduler:
```bash
$ rails scheduler:start
```

You can then queue or run jobs by calling:
```ruby
ExampleSchedulableModel.perform_later('ExampleSchedulableJob', 10) # to queue
ExampleSchedulableModel.perform_now('ExampleSchedulableJob', 10) # to perform immediately
```
Both methods create a document of `ExampleSchedulableModel` and put it in queue.
The __perform_now__ method skips the scheduler and performs the job immediately, instead the __perform_later__ leaves the performing task to the scheduler.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
