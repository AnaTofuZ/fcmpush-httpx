# frozen_string_literal: true

require 'googleauth'
require 'httpx'
require 'fcmpush/configuration'

require 'fcmpush/httpx/client'
require 'fcmpush/httpx/version'

module Fcmpush
  module Httpx
    class Error < StandardError; end

    DOMAIN = 'https://fcm.googleapis.com'.freeze

    class << self
      def build(project_id, domain: DOMAIN)
        ::Fcmpush::Httpx::Client.new(domain, project_id, Fcmpush::Configuration.new)
      end
      alias new build
    end
  end
end
