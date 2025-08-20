module Reporting
  class Engine < ::Rails::Engine
    isolate_namespace Reporting
    config.generators.api_only = true
  end
end
