# frozen_string_literal: true

module Reporting
  # Controller for managing report requests
  class ReportsController < ActionController::API
    # host define current_user e autorização via lambdas da config

    # POST /reporting/reports
    def create
      kind = params.require(:kind).to_s
      Reporting.registry.fetch!(kind) # valida existência

      req = ReportRequest.create!(
        kind: kind,
        params: params[:params] || {},
        requester: [current_user, current_user&.class&.name].compact.presence && current_user
      )
      GenerateReportJob.perform_later(req.id)
      render json: { token: req.token, status: req.status }, status: :accepted
    end

    # GET /reporting/reports/:token
    def show
      req = ReportRequest.find_by!(token: params[:token])
      authorize!(req)

      case req.status
      when "done"
        url = req.file.blob.service_url(expires_in: Reporting.config.expires_in)
        render json: { status: req.status, download_url: url }
      when "failed"
        render json: { status: req.status, error: req.error_message }, status: :unprocessable_entity
      else
        render json: { status: req.status }
      end
    end

    private

    def current_user
      Reporting.config.current_user_proc.call(self)
    end

    def authorize!(req)
      ok = Reporting.config.authorize_proc.call(self, req)
      head :forbidden unless ok
    end
  end
end
