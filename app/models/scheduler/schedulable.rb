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
      # Immediately update the status to the given one.
      #
      # @param [Symbol] status the status to update.
      #
      # @return [nil]
      def status!(status)
        self.update(status: status)
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
