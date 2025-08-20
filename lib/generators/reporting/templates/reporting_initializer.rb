# frozen_string_literal: true

# Configuração padrão para a gem Reporting
Reporting.configure do
  # fila, expiração do link, current_user e autorização
  self.queue_name = :reports
  self.expires_in = 20.minutes
  self.current_user_proc = ->(controller) { controller.try(:current_user) }
  self.authorize_proc = ->(controller, report) { report.requester_id == controller.current_user&.id }

  # registre seus relatórios
  # register :sales, "Reports::SalesReportService"
  # register :inventory, "Reports::InventoryReportService"
end
