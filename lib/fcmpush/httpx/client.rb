
require "httpx"
require "googleauth"

require "fcmpush/httpx/exceptions"

module Fcmpush
  module Httpx
    V1_ENDPOINT_PREFIX = "/v1/projects/".freeze
    V1_ENDPOINT_SUFFIX = "/messages:send".freeze
    TOPIC_DOMAIN = "https://iid.googleapis.com".freeze
    TOPIC_ENDPOINT_PREFIX = "/iid/v1".freeze

    class Client
      attr_reader :domain, :path, :httpx, :configuration, :access_token, :access_token_expiry

      def initialize(domain:, project_id:, configuration:, **options)
        @domain = domain
        @project_id = project_id
        @path = V1_ENDPOINT_PREFIX + project_id.to_s + V1_ENDPOINT_SUFFIX
        @configuration = configuration.dup

        @httpx = ::HTTPX.plugin(:persistent)
        configure_client(options)

        access_token_response = v1_authorize
        @access_token = access_token_response["access_token"]
        @access_token_expiry = Time.now.utc + access_token_response["expires_in"].to_i
      end

      def v1_authorize
        @auth ||= create_credentials
        @auth.fetch_access_token
      end

      def configure_client(options)
        op = {}
        op[:timeout] = {
          connect_timeout: options[:connect_timeout] || configuration.connect_timeout,
          write_timeout: options[:write_timeout] || configuration.write_timeout,
          read_timeout: options[:read_timeout] || configuration.read_timeout
        }
        op
      end

      def push(body, query: {}, headers: {})
        uri = URI.join(domain, path)
        uri.query = URI.encode_www_form(query) unless query.empty?

        refresh_access_token
        headers = v1_authorized_header(headers)
        response = httpx.post(uri.to_s, json: body.is_a?(String) ? JSON.parse(body) : body, headers:)
        exception_handler(response)
        response
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError => e
        raise NetworkError, "A network error occurred: #{e.class} (#{e.message})"
      end

      private

      def create_credentials
        if configuration.json_key_io
          create_credentials_from_json_key
        else
          create_credentials_from_env
        end
      end

      def create_credentials_from_json_key
        io = get_json_key_io
        io.rewind if io.respond_to?(:read)
        Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: io,
          scope: configuration.scope
        )
      end

      def get_json_key_io
        if configuration.json_key_io.respond_to?(:read)
          configuration.json_key_io
        elsif !configuration.json_key_io.nil? && File.exist?(configuration.json_key_io)
          File.open(configuration.json_key_io)
        end
      end

      def create_credentials_from_env
        Google::Auth::ServiceAccountCredentials.make_creds(scope: configuration.scope)
      end

      def refresh_access_token
        return if access_token_expiry > Time.now.utc + 300

        access_token_response = v1_authorize
        @access_token = access_token_response["access_token"]
        @access_token_expiry = Time.now.utc + access_token_response["expires_in"]
      end

      def v1_authorized_header(headers)
        headers.merge("Content-Type" => "application/json",
                      "Accept" => "application/json",
                      "Authorization" => "Bearer #{access_token}")
      end

      def exception_handler(response)
        error = STATUS_TO_EXCEPTION_MAPPING[response.status]
        binding.irb
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
