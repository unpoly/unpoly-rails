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
        request_url_without_up_params = up.request_url_without_up_params
        unless request_url_without_up_params == request.original_url
          response.headers['X-Up-Location'] = up.request_url_without_up_params
        end

        response.headers['X-Up-Method'] = request.method
      end

    end
  end
end

ActiveSupport.on_load(:action_controller_base) do
  include Unpoly::Rails::RequestEchoHeaders
end
