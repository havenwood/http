require 'forwardable'

require 'http/headers'
require 'http/content_type'
require 'http/mime_type'
require 'http/response/status'

module HTTP
  class Response
    extend Forwardable

    include HTTP::Headers::Mixin

    attr_reader :status
    attr_reader :body
    attr_reader :uri

    # Status aliases! TIMTOWTDI!!! (Want to be idiomatic? Just use status :)
    alias_method :code,        :status
    alias_method :status_code, :status

    def initialize(status, version, headers, body, uri = nil) # rubocop:disable ParameterLists
      @version, @body, @uri = version, body, uri

      @status  = HTTP::Response::Status.new status
      @headers = HTTP::Headers.coerce(headers || {})
    end

    def_delegator :status, :reason

    # Returns an Array ala Rack: `[status, headers, body]`
    def to_a
      [status.to_i, headers.to_h, body.to_s]
    end

    # Return the response body as a string
    def to_s
      body.to_s
    end
    alias_method :to_str, :to_s

    # Flushes body and returns self-reference
    def flush
      body.to_s
      self
    end

    # Parsed Content-Type header
    # @return [HTTP::ContentType]
    def content_type
      @content_type ||= ContentType.parse headers['Content-Type']
    end

    # MIME type of response (if any)
    # @return [String, nil]
    def mime_type
      @mime_type ||= content_type.mime_type
    end

    # Charset of response (if any)
    # @return [String, nil]
    def charset
      @charset ||= content_type.charset
    end

    # Parse response body with corresponding MIME type adapter.
    #
    # @param [#to_s] as Parse as given MIME type
    #   instead of the one determined from headers
    # @raise [Error] if adapter not found
    # @return [Object]
    def parse(as = nil)
      MimeType[as || mime_type].decode to_s
    end

    # Inspect a response
    def inspect
      "#<#{self.class}/#{@version} #{status.inspect} #{headers.inspect}>"
    end
  end
end
