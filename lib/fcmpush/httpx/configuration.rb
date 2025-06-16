module Fcmpush
  module Httpx
    # Configuration class for Fcmpush::Httpx
    class Configuration
      attr_accessor :scope, :json_key_io, :proxy, :read_timeout, :write_timeout, :connect_timeout

      def initialize
        @scope = ["https://www.googleapis.com/auth/firebase.messaging"]

        @json_key_io = nil

        # default httpx times
        @read_timeout = 60
        @connect_timeout = 60
        @write_timeout = 60

        # Or Environment Variable
        # ENV['GOOGLE_ACCOUNT_TYPE'] = 'service_account'
        # ENV['GOOGLE_CLIENT_ID'] = '000000000000000000000'
        # ENV['GOOGLE_CLIENT_EMAIL'] = 'xxxx@xxxx.iam.gserviceaccount.com'
        # ENV['GOOGLE_PRIVATE_KEY'] = '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n'
      end
    end
  end
end