require_relative "lib/reporting/version"

Gem::Specification.new do |spec|
  spec.name        = "reporting"
  spec.version     = Reporting::VERSION
  spec.authors     = ["Alef ojeda de Oliveira"]
  spec.email       = ["nemubatubag@gmail.com"]
  spec.homepage    = "https://github.com/nemuba/reporting"
  spec.summary     = "Projeto para geração de relatórios."
  spec.description = "Este projeto tem como objetivo facilitar a geração de relatórios em aplicações Ruby on Rails."
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.0"

  # Arquivos
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "README.md", "Rakefile"]
  end
  spec.require_paths = ["lib"]

  # Dependências de runtime (compatível 7.0.4 .. < 7.2)
  spec.add_dependency "rails", ">= 7.0.4", "< 7.2"   # cobre actionpack, activejob, activestorage etc.
  spec.add_dependency "puma"                     # servidor web
  spec.add_dependency "sidekiq", ">= 6"
  spec.add_dependency "sqlite3", "~> 1.6"       # banco do dummy app

  # Dependências de desenvolvimento (opcional, para rodar specs/dummy app)
  spec.add_development_dependency "rspec-rails", "~> 6.1"
  spec.add_development_dependency "sqlite3", "~> 1.6"
  spec.add_development_dependency "rubocop-rails", "~> 2.33"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "rubocop-rspec_rails"
end
