module Staffomatic

  # Configuration options for {Client}, defaulting to values
  # in {Default}
  module Configurable
    # @!attribute [w] access_token
    #   @see https://developer.github.com/v3/oauth/
    #   @return [String] OAuth2 access token for authentication
    # @!attribute account
    #   @return [String] Account URL for API requests.
    # @!attribute api_endpoint
    #   @return [String] Base URL for API requests.
    # @!attribute auto_paginate
    #   @return [Boolean] Auto fetch next page of results until rate limit reached
    # @!attribute client_id
    #   @see https://developer.github.com/v3/oauth/
    #   @return [String] Configure OAuth app key
    # @!attribute [w] client_secret
    #   @see https://developer.github.com/v3/oauth/
    #   @return [String] Configure OAuth app secret
    # @!attribute default_media_type
    #   @see https://developer.github.com/v3/media/
    #   @return [String] Configure preferred media type (for API versioning, for example)
    # @!attribute connection_options
    #   @see https://staffomatic.com/lostisland/faraday
    #   @return [Hash] Configure connection options for Faraday
    # @!attribute email
    #   @return [String] Staffomatic email for Basic Authentication
    # @!attribute middleware
    #   @see https://staffomatic.com/lostisland/faraday
    #   @return [Faraday::Builder or Faraday::RackBuilder] Configure middleware for Faraday
    # @!attribute [w] password
    #   @return [String] Staffomatic password for Basic Authentication
    # @!attribute per_page
    #   @return [String] Configure page size for paginated results. API default: 30
    # @!attribute proxy
    #   @see https://staffomatic.com/lostisland/faraday
    #   @return [String] URI for proxy server
    # @!attribute user_agent
    #   @return [String] Configure User-Agent header for requests.
    # @!attribute content_type
    #   @return [String] Configure Content-Type header for requests.

    attr_accessor :access_token, :auto_paginate, :client_id,
                  :client_secret, :default_media_type, :connection_options,
                  :middleware, :per_page, :proxy, :user_agent, :content_type
    attr_writer :password, :api_endpoint, :email, :account, :scheme

    class << self

      # List of configurable keys for {Staffomatic::Client}
      # @return [Array] of option keys
      def keys
        @keys ||= [
          :access_token,
          :account,
          :api_endpoint,
          :auto_paginate,
          :client_id,
          :client_secret,
          :connection_options,
          :default_media_type,
          :email,
          :middleware,
          :per_page,
          :password,
          :proxy,
          :scheme,
          :user_agent,
          :content_type
        ]
      end
    end

    # Set configuration options using a block
    def configure
      yield self
    end

    # Reset configuration options to default values
    def reset!
      Staffomatic::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", Staffomatic::Default.options[key])
      end
      self
    end
    alias setup reset!

    def api_endpoint
      File.join(@api_endpoint, "")
    end

    def scheme
      @scheme
    end

    def account
      @account
    end

    # Memoizes the user.email by fetching user once (see users.rb)
    def email
      @email ||= begin
        user.email if token_authenticated?
      end
    end

    private

    def options
      Hash[Staffomatic::Configurable.keys.map{|key| [key, instance_variable_get(:"@#{key}")]}]
    end

    def fetch_client_id_and_secret(overrides = {})
      opts = options.merge(overrides)
      opts.values_at :client_id, :client_secret
    end
  end
end
