require "rails"
require "active_storage/engine"
require_relative "reporting/engine"
require_relative "reporting/config"
require_relative "reporting/registry"

module Reporting
  def self.configure(&block) = Config.instance.instance_eval(&block)
  def self.config = Config.instance
  def self.registry = Registry.instance
end
