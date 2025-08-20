# frozen_string_literal: true

# Criação da tabela de solicitações de relatórios
class CreateReportingReportRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :reporting_report_requests, id: :uuid do |t|
      t.string  :token, null: false, index: { unique: true }, comment: "Token da solicitação"
      t.integer :status, null: false, default: 0, comment: "Status (0: pending, 1: processing, 2: done, 3: failed)"
      t.json   :params, null: false, default: {}, comment: "Parâmetros da solicitação em formato JSON"
      t.string  :kind, null: false, comment: "Tipo da solicitação"
      t.references :requester, polymorphic: true, type: :uuid, null: false, comment: "Solicitante da requisição"
      t.string :error_message, comment: "Mensagem de erro, se houver"
      t.string :service_name, comment: "Nome do serviço que processou a solicitação"
      t.string :remote_ip, comment: "Endereço IP remoto do solicitante"
      t.datetime :started_at, comment: "Data e hora de início da solicitação"
      t.datetime :finished_at, comment: "Data e hora de conclusão da solicitação"

      # Indexes
      t.index :status, name: "idx_status", comment: "Índice para o status da solicitação"
      t.index :kind, name: "idx_kind", comment: "Índice para o tipo da solicitação"
      t.index :started_at, name: "idx_started_at", comment: "Índice para a data de início da solicitação"
      t.index :finished_at, name: "idx_finished_at", comment: "Índice para a data de conclusão da solicitação"
      t.index [:requester_type, :requester_id], name: "idx_requester",
                                                comment: "Índice para o solicitante da requisição"

      t.timestamps
    end
  end
end
