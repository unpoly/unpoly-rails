module Unpoly
  module Rails
    ##
    # Installs a `before_action` into all controllers which echoes the
    # request's URL as a response header `X-Up-Location` and the request's
    # HTTP method as `X-Up-Method`.
    #
    # The Unpoly frontend requires these headers to detect redirects,
    # which are otherwise undetectable for an AJAX client.
    module RequestEchoHeaders

      def self.included(base)
        if base.respond_to?(:before_action)
          base.before_action :set_up_request_echo_headers
        else
          base.before_filter :set_up_request_echo_headers
        end
      end

      private

      def set_up_request_echo_headers
        location = up.request_url_without_up_params

        # The browser never sends a #hash to the server.
        # When we redirected to a URL with a #hash, we passed it as a param.
        if (hash = up.location_hash)
          location += "##{hash}"
        end

        unless location == request.original_url
          response.headers['X-Up-Location'] = location
        end

        response.headers['X-Up-Method'] = request.method
      end

    end
  end
end

ActiveSupport.on_load(:action_controller_base) do
  include Unpoly::Rails::RequestEchoHeaders
end
