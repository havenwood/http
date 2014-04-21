module Faraday
  class Adapter
    # The Ruby HTTP Gem adapter for Faraday.
    class HTTP < Faraday::Adapter
      dependency 'http'

      # Perform request
      def call(env)
        super

        fail 'not implemented yet'
      end
    end
  end
end
