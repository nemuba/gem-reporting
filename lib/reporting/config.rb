require "singleton"

module Reporting
  # Configuração do sistema de relatórios
  class Config
    include Singleton

    attr_accessor :queue_name, :expires_in, :current_user_proc, :authorize_proc

    def initialize
      @queue_name = :reports
      @expires_in = 15.minutes
      # quem é o usuário atual no host app?
      @current_user_proc = ->(controller) { controller.try(:current_user) }
      # autorização (pode baixar/ver?)
      @authorize_proc = ->(_controller, _report_request) { true }
    end

    def register(kind, service_class)
      Reporting.registry.register(kind.to_s, service_class)
    end
  end
end
