module Scheduler
  module Schedulable

    ##
    # Possible schedulable statuses.
    STATUSES = [ :queued, :running, :completed, :error, :locked ]

    ##
    # Possible log levels.
    LOG_LEVELS = [ :debug, :info, :warn, :error ]

    def self.included(base)

      base.class_eval do
        include Mongoid::Document

        field :class_name,              type: String
        field :args,                    type: Array,      default: []
        field :scheduled_at,            type: DateTime
        field :executed_at,             type: DateTime
        field :completed_at,            type: DateTime
        field :pid,                     type: Integer
        field :status,                  type: Symbol,     default: :queued
        field :logs,                    type: Array,      default: []
        field :progress,                type: Float,      default: 0.0
        field :error,                   type: String
        field :backtrace,               type: String

        scope :queued,      -> { where(status: :queued) }
        scope :running,     -> { where(status: :running) }
        scope :completed,   -> { where(status: :completed) }
        scope :in_error,    -> { where(status: :error) }
        scope :locked,      -> { where(status: :locked) }

        validates_presence_of   :class_name

        after_save              :broadcast

        class << self
        
          ##
          # Returns possible statuses.
          #
          # @return [Array<Symbol>] possible statuses.
          def statuses
            Scheduler::Schedulable::STATUSES
          end

          ##
          # Returns possible log levels.
          #
          # @return [Array<Symbol>] possible log levels.
          def log_levels
            Scheduler::Schedulable::LOG_LEVELS
          end

          ##
          # Creates an instance of this class and calls :perform_later.
          #
          # @param [String] job_class the class of the job to run.
          # @param [Array] *job_args job arguments
          #
          # @return [Object] the created job.
          def perform_later(job_class, *job_args)
            self.create(class_name: job_class, args: job_args).perform_later
          end

          ##
          # Creates an instance of this class and calls :perform_now.
          #
          # @param [String] job_class the class of the job to run.
          # @param [Array] *job_args job arguments
          #
          # @return [Object] the created job.
          def perform_now(job_class, *job_args)
            self.create(class_name: job_class, args: job_args).perform_now
          end

        end

      end

      ##
      # Gets ActiveJob's job class.
      #
      # @return [Class] the ActiveJob's job class.
      def job_class
        self.class_name.constantize
      end

      ##
      # Schedules the job.
      #
      # @return [Object] itself.
      def schedule
        self.scheduled_at = Time.current
        self.status = :queued
        self.logs = []
        self.progress = 0.0
        self.unset(:error)
        self.unset(:backtrace)
        self.unset(:completed_at)
        self.unset(:executed_at)
        self.save
        if block_given?
          yield self
        else self end
      end

      ##
      # Performs job when queue is available.
      # On test or development env, the job is performed by ActiveJob queue,
      # if configured on the Scheduler configuration.
      # On production env, the job is performed only with a Scheduler::MainProcess.
      #
      # @return [Object] the job class.
      def perform_later
        self.schedule
        if Rails.env.development? or Rails.env.test?
          if Scheduler.configuration.perform_jobs_in_test_or_development
            job_class.set(wait: 5.seconds).perform_later(self.class.name, self.id.to_s, *self.args)
          end
        end
        self
      end

      ##
      # Performs job when queue is available.
      # On test or development env, the job is performed with ActiveJob.
      # On production env, the job is performed with Scheduler.
      #
      # @return [Object] the job class.
      def perform_now
        self.schedule
        job_class.perform_now(self.class.name, self.id.to_s, *self.args)
        self
      end

      ##
      # Immediately update the status to the given one.
      #
      # @param [Symbol] status the status to update.
      #
      # @return [nil]
      def status!(status)
        self.update(status: status)
      end

      ##
      # Immediately increases progress to the given amount.
      #
      # @param [Float] amount the given progress amount.
      def progress!(amount)
        self.update(progress: amount.to_f) if amount.numeric?
      end

      ##
      # Immediately increases progress by the given amount.
      #
      # @param [Float] amount the given progress amount.
      def progress_by!(amount)
        self.update(progress: progress + amount.to_f) if amount.numeric?
      end

      ##
      # Registers a log message with the given level.
      def log(level, message)
        raise ArgumentError.new("The given log level '#{level}' is not valid. "\
          "Valid log levels are: #{LOG_LEVELS.join(', ')}") unless level.in? LOG_LEVELS
        self.update(logs: logs.push([level, message]))
      end

      ##
      # Broadcasts a job updating event.
      #
      # @return [nil]
      def broadcast
        { status: status, logs: logs }
      end

    end

  end
end
