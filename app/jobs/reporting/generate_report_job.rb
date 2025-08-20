# frozen_string_literal: true

module Reporting
  # Job for generating reports
  class GenerateReportJob < ApplicationJob
    queue_as { Reporting.config.queue_name }

    def perform(report_request_id)
      Reporting::GenerateReportService.new(report_request_id).call
    end
  end
end
