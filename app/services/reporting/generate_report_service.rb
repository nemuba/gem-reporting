# frozen_string_literal: true

module Reporting
  # Service responsible for orchestrating report generation.
  #
  # Example usage:
  #   Reporting::GenerateReportService.new(report_request_id).call
  #
  # This service fetches the ReportRequest, validates its status, instantiates the correct
  # report service, executes the generation, attaches the file, and updates the status.
  class GenerateReportService
    # @param report_request_id [Integer] ID of the ReportRequest to be processed
    def initialize(report_request_id)
      @report_request_id = report_request_id
    end

    # Executes the report generation flow.
    #
    # Fetches the ReportRequest, validates its status, processes and handles failures.
    # @return [void]
    def call
      req = fetch_and_validate_request
      return unless req

      process_request(req)
    rescue StandardError => e
      handle_failure(req, e)
      raise e
    end

    private

    # Returns the current time
    # @return [Time]
    def time_current
      Time.current
    end

    def process(req, &block)
      update_status_processing(req)
      block.call(req) if block_given?
      update_status_done(req)
    end

    # Fetches the ReportRequest and validates if it is ready for processing.
    # @return [ReportRequest, nil] The valid request or nil
    def fetch_and_validate_request
      req = ReportRequest.find(@report_request_id)
      return nil unless req.status_queued? || req.status_failed?

      req
    end

    # Processes the ReportRequest: updates status, generates the report, attaches the file, and finalizes.
    # @param req [ReportRequest]
    # @return [void]
    def process_request(req)
      process(req) do |request|
        service = build_service(request)
        io, filename, content_type = service.call
        attach_file(request, io, filename, content_type)
      end
    end

    # Updates the ReportRequest status to :processing
    # @param req [ReportRequest]
    def update_status_processing(req)
      req.update!(status: :processing, started_at: time_current)
    end

    # Instantiates the service responsible for report generation
    # @param req [ReportRequest]
    # @return [Object] Service instance
    def build_service(req)
      service_klass = Reporting.registry.fetch!(req.kind).constantize
      service_klass.new(symbolize(req.params), context: { report_request_id: req.id })
    end

    # Attaches the generated file to the ReportRequest
    # @param req [ReportRequest]
    # @param io [IO]
    # @param filename [String]
    # @param content_type [String]
    def attach_file(req, io, filename, content_type)
      req.file.attach(io: io, filename: filename, content_type: content_type)
    end

    # Updates the ReportRequest status to :done
    # @param req [ReportRequest]
    def update_status_done(req)
      req.update!(status: :done, finished_at: time_current)
    end

    # Updates the ReportRequest status to :failed in case of error
    # @param req [ReportRequest, nil]
    # @param error [Exception]
    def handle_failure(req, error)
      return unless req

      req.update!(status: :failed, error_message: error.message, finished_at: time_current)
    rescue StandardError
      nil
    end

    # Converts hash keys to symbols
    # @param h [Hash, nil]
    # @return [Hash]
    def symbolize(hash)
      (hash || {}).transform_keys(&:to_sym)
    end
  end
end
