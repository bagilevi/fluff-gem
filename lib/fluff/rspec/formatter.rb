RSpec::Support.require_rspec_core "formatters/base_formatter"
require 'json'
require 'redis'
require 'securerandom'

module Fluff
  module Rspec
    class Formatter < RSpec::Core::Formatters::BaseFormatter
      RSpec::Core::Formatters.register self, :start, :example_passed, :example_failed, :example_pending, :message, :dump_summary, :seed, :close

      attr_reader :output_hash

      def initialize(output)
        super
        @run_uuid = ENV.fetch('FLUFF_RUN_UUID', SecureRandom.uuid)
        @summary_hash = {}
        @redis = Redis.new(url: ENV.fetch('FLUFF_REDIS_URL'))
      end

      def start(notification)
        emit(
          :type => 'start',
          :version => RSpec::Core::Version::STRING,
          :project_path => (defined?(Rails) ? Rails.root.to_s : Dir.pwd),
          :lib_paths => Gem.loaded_specs.map { |gem_name, gem_spec| [gem_name, gem_spec.full_gem_path] }
        )
      end

      def example_passed(notification)
        emit format_example(notification.example)
      end

      def example_failed(notification)
        emit format_example(notification.example)
      end

      def example_pending(notification)
        emit format_example(notification.example)
      end

      def message(notification)
        emit :type => 'message', :message => notification.message
      end

      def dump_summary(summary)
        @summary_hash.merge!(
          :type => 'summary',
          :duration => summary.duration,
          :example_count => summary.example_count,
          :failure_count => summary.failure_count,
          :pending_count => summary.pending_count
        )
      end

      def seed(notification)
        return unless notification.seed_used?
        @summary_hash[:seed] = notification.seed
      end

      def close(_notification)
        emit @summary_hash
      end

      private

      def emit(payload)
        payload = { :run_uuid => @run_uuid }.merge(payload)
        # puts JSON.pretty_generate(payload)
        @redis.publish "fluff_shouts", JSON.generate(payload)
      end

      def format_example(example)
        payload = {
          :type => 'example_result',
          :id => example.id,
          :description => example.description,
          :full_description => example.full_description,
          :status => example.execution_result.status.to_s,
          :file_path => example.metadata[:file_path],
          :line_number  => example.metadata[:line_number],
          :run_time => example.execution_result.run_time,
          :pending_message => example.execution_result.pending_message,
        }
        if (e = example.exception)
          payload[:exception] = {
            :class => e.class.name,
            :message => e.message,
            :backtrace => e.backtrace,
          }
        end
        payload
      end
    end
  end
end
