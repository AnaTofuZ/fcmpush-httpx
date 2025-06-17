
require "httpx"
require "googleauth"

require 'fcmpush/client'
require "fcmpush/httpx/exceptions"

module Fcmpush
  module Httpx
    class Client < ::Fcmpush::Client
      DEFAULT_HTTPX_TIME = 60

      attr_reader :domain, :path, :connection, :configuration, :server_key, :access_token, :access_token_expiry, :httpx

      def initialize(domain, project_id, configuration, **options)
        @domain = domain
        @project_id = project_id
        @path = V1_ENDPOINT_PREFIX + project_id.to_s + V1_ENDPOINT_SUFFIX
        @options = {}.merge(options)
        @configuration = configuration.dup
        access_token_response = v1_authorize
        @access_token = access_token_response['access_token']
        @access_token_expiry = Time.now.utc + access_token_response['expires_in']
        # @server_key = configuration.server_key
        @httpx = HTTPX.plugin(:persistent, configure_client(options))
      end


      def push(body, query: {}, headers: {})
        response = do_push_request(body, query, headers)
        exception_handler(response)
        response
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError => e
        raise NetworkError, "A network error occurred: #{e.class} (#{e.message})"
      end

      def subscribe(topic, *instance_ids, query: {}, headers: {})
        response = do_subscription_request(topic, *instance_ids, :subscribe, query, headers)
        exception_handler(response)
        response
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError => e
        raise NetworkError, "A network error occurred: #{e.class} (#{e.message})"
      end

      def unsubscribe(topic, *instance_ids, query: {}, headers: {})
        response = do_subscription_request(topic, *instance_ids, :unsubscribe, query, headers)
        exception_handler(response)
        response
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError => e
        raise NetworkError, "A network error occurred: #{e.class} (#{e.message})"
      end

      private

      def configure_client(options)
        op = {}
        op[:timeout] = {
          connect_timeout: options[:connect_timeout] || DEFAULT_HTTPX_TIME,
          write_timeout: options[:write_timeout] || DEFAULT_HTTPX_TIME,
          read_timeout: options[:read_timeout] || DEFAULT_HTTPX_TIME
        }
        op
      end

      def do_push_request(body, query, headers)
        uri = URI.join(domain, path)
        uri.query = URI.encode_www_form(query) unless query.empty?
        headers = v1_authorized_header(headers)
        httpx.post(uri.to_s, json: body.is_a?(String) ? JSON.parse(body) : body, headers:)
      end

      def do_subscription_request(topic, *instance_ids, action, query, headers)
        suffix = action == :subscribe ? ":batchAdd" : ":batchRemove"

        uri = URI.join(TOPIC_DOMAIN, TOPIC_ENDPOINT_PREFIX + suffix)
        uri.query = URI.encode_www_form(query) unless query.empty?

        headers = v1_authorized_header(headers)
        headers['access_token_auth'] = 'true'
        httpx.post(uri.to_s, json: make_subscription_body(topic, instance_ids), headers:)
      end

      def exception_handler(response)
        error = STATUS_TO_EXCEPTION_MAPPING[response.status]
        if error
          raise error.new(
            "Received an error response #{response.status} #{error.to_s.split('::').last}: #{response.body.to_s}",
            response
          )
        end
        response
      end
    end
  end
end
