require "singleton"

module Reporting
  # Registro de serviços de relatórios
  class Registry
    include Singleton

    def initialize = @map = {}
    def register(kind, klass) = @map[kind] = klass
    def fetch!(kind) = @map.fetch(kind) { raise ArgumentError, "Unknown report kind: #{kind}" }
  end
end
