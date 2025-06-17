# frozen_string_literal: true

require 'googleauth'
require 'httpx'

require 'fcmpush/httpx/configuration'
require 'fcmpush/httpx/client'
require 'fcmpush/httpx/version'

module Fcmpush
  module Httpx
    class Error < StandardError; end

    DOMAIN = 'https://fcm.googleapis.com'.freeze

    class << self
      def build(project_id, domain: DOMAIN)
        ::Fcmpush::Httpx::Client.new(domain:, project_id:, configuration:)
      end
      alias new build
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.reset
      @configuration = Configuration.new
    end
  end
end
