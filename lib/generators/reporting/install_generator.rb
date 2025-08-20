# frozen_string_literal: true

require 'rails/generators'

module Reporting
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Cria o arquivo de initializer para configuração do Reporting.'

      def copy_initializer
        template 'reporting_initializer.rb', 'config/initializers/reporting.rb'
      end
    end
  end
end
