module Unpoly
  module Rails
    ##
    # This object allows the server to inspect the current request
    # for Unpoly-related concerns such as "is this a page fragment update?".
    #
    # Available through the `#up` method in all controllers, helpers and views.
    class Change
      include Memoized
      include FieldDefinition

      def initialize(controller)
        @controller = controller
      end

      # Generate helpers to get, set and cast fields in request and response headers.
      field Field::String.new(:version)
      field Field::String.new(:target)
      field Field::String.new(:fail_target)
      field Field::SeparatedValues.new(:validate_names), request_header_name: 'X-Up-Validate'
      field Field::String.new(:mode)
      field Field::String.new(:fail_mode)
      field Field::Hash.new(:context, default: -> { {} }), method: :input_context
      field Field::Hash.new(:fail_context, default: -> { {} }), method: :input_fail_context
      field Field::Hash.new(:context_changes, default: -> { {} }), response_header_name: 'X-Up-Context'
      field Field::Array.new(:events, default: -> { [] })
      field Field::String.new(:clear_cache)
      field Field::Time.new(:reload_from_time)

      ##
      # Returns whether the current request is an
      # [page fragment update](https://unpoly.com/up.replace) triggered by an
      # Unpoly frontend.
      def up?
        # This will eventually just check for the X-Up-Version header.
        # Just in case a user still has an older version of Unpoly running on the frontend,
        # we also check for the X-Up-Target header.
        version.present? || target.present?
      end

      alias_method :unpoly?, :up?

      ##
      # Returns the version of Unpoly running in the browser that made
      # the request.
      memoize def version
        version_from_request
      end

      ##
      # Returns the CSS selector for a fragment that Unpoly will update in
      # case of a successful response (200 status code).
      #
      # The Unpoly frontend will expect an HTML response containing an element
      # that matches this selector.
      #
      # Server-side code is free to optimize its successful response by only returning HTML
      # that matches this selector.
      def target
        @server_target || target_from_request
      end

      def target=(new_target)
        @server_target = new_target
      end

      def target_changed?
        target != target_from_request
      end

      ##
      # Returns whether the given CSS selector is targeted by the current fragment
      # update in case of a successful response (200 status code).
      #
      # Note that the matching logic is very simplistic and does not actually know
      # how your page layout is structured. It will return `true` if
      # the tested selector and the requested CSS selector matches exactly, or if the
      # requested selector is `body` or `html`.
      #
      # Always returns `true` if the current request is not an Unpoly fragment update.
      def target?(tested_target)
        test_target(target, tested_target)
      end

      def render_nothing(status: :no_content, deprecation: true)
        if deprecation
          ActiveSupport::Deprecation.warn("up.render_nothing is deprecated. Use head(:no_content) instead.")
        end
        self.target = ':none'
        controller.head(status)
      end

      ##
      # Returns the CSS selector for a fragment that Unpoly will update in
      # case of an failed response. Server errors or validation failures are
      # all examples for a failed response (non-200 status code).
      #
      # The Unpoly frontend will expect an HTML response containing an element
      # that matches this selector.
      #
      # Server-side code is free to optimize its response by only returning HTML
      # that matches this selector.
      #
      memoize def fail_target
        @server_target || fail_target_from_request
      end

      ##
      # Returns whether the given CSS selector is targeted by the current fragment
      # update in case of a failed response (non-200 status code).
      #
      # Note that the matching logic is very simplistic and does not actually know
      # how your page layout is structured. It will return `true` if
      # the tested selector and the requested CSS selector matches exactly, or if the
      # requested selector is `body` or `html`.
      #
      # Always returns `true` if the current request is not an Unpoly fragment update.
      def fail_target?(tested_target)
        test_target(fail_target, tested_target)
      end

      ##
      # Returns whether the given CSS selector is targeted by the current fragment
      # update for either a success or a failed response.
      #
      # Note that the matching logic is very simplistic and does not actually know
      # how your page layout is structured. It will return `true` if
      # the tested selector and the requested CSS selector matches exactly, or if the
      # requested selector is `body` or `html`.
      #
      # Always returns `true` if the current request is not an Unpoly fragment update.
      def any_target?(tested_target)
        target?(tested_target) || fail_target?(tested_target)
      end

      ##
      # If the current form submission is a [validation](https://unpoly.com/input-up-validate),
      # this returns the name attributes of the form fields that has triggered
      # the validation.
      #
      # Note that multiple validating form fields may be batched into a single request.
      def validate_names
        validate_names_from_request
      end

      memoize def validate_name
        if validating?
          validates_names.first
        end
      end

      ##
      # Returns whether the current form submission should be
      # [validated](https://unpoly.com/input-up-validate) (and not be saved to the database).
      def validate?
        validate_names.present?
      end

      alias validating? validate?

      ##
      # TODO: Docs
      memoize def mode
        mode_from_request
      end

      ##
      # TODO: Docs
      memoize def fail_mode
        fail_mode_from_request
      end

      ##
      # Returns the context object as sent from the frontend,
      # before any changes made on the server.
      #
      memoize def input_context
        input_context_from_request
      end

      ##
      # TODO: Docs
      memoize def context
        Context.new(input_context, unfinalized_context_changes)
      end

      memoize def unfinalized_context_changes
        context_changes_from_params&.dup || {}
      end

      def context_changes
        context.finalize_changes
        fail_context.finalize_changes
        unfinalized_context_changes
      end

      ##
      # Returns the context object for failed responses as
      # sent from the frontend, before any changes made on the server.
      #
      memoize def input_fail_context
        input_fail_context_from_request
      end

      ##
      # TODO: Docs
      memoize def fail_context
        Context.new(input_fail_context, unfinalized_context_changes)
      end

      memoize def events
        # Events are outgoing only. They wouldn't be passed as a request header.
        # We might however pass them as params so they can survive a redirect.
        events_from_params.dup
      end

      ##
      # TODO: Docs
      def emit(*args)
        event_plan = args.extract_options!

        # We support two call styles:
        # up.emit('event:type', prop: value)
        # up.emit(type: 'event:type', prop: value)
        if args[0].is_a?(String)
          event_plan[:type] = args[0]
        end

        # Track the given props in an array. If the method is called a second time,
        # we can re-set the X-Up-Events header with the first and second props hash.
        events.push(event_plan)
      end

      ##
      # Forces Unpoly to use the given string as the document title when processing
      # this response.
      #
      # This is useful when you skip rendering the `<head>` in an Unpoly request.
      def title=(new_title)
        # We don't make this a field since it belongs to *this* response
        # and should not survive a redirect.
        response.headers['X-Up-Title'] = new_title
      end

      def after_action
        write_events_to_response_headers

        write_clear_cache_to_response_headers

        if context_changes.present?
          write_context_changes_to_response_headers
        end

        if target_changed?
          # Only write the target to the response if it has changed.
          # The client might have a more abstract target like :main
          # that we don't want to override with an echo of the first match.
          write_target_to_response_headers
        end
      end

      def url_with_field_values(url)
        append_params_to_url(url, fields_as_params)
      end

      # Used by RequestEchoHeaders to prevent up[...] params from showing up
      # in a history URL.
      def request_url_without_up_params
        original_url = request.original_url

        original_url.include?(Field::PARAM_PREFIX) or return original_url

        # Parse the URL to extract the ?query part below.
        uri = URI.parse(original_url)

        # This parses the query as a flat list of key/value pairs.
        params = Rack::Utils.parse_query(uri.query)

        # We only used the up[...] params to transport headers, but we don't
        # want them to appear in a history URL.
        non_up_params = params.reject { |key, _value| key.starts_with?(Field::PARAM_PREFIX) }

        append_params_to_url(uri.path, non_up_params)
      end

      memoize def layer
        Layer.new(self, mode: mode, context: context)
      end

      memoize def fail_layer
        Layer.new(self, mode: fail_mode, context: fail_context)
      end

      memoize def cache
        Cache.new(self)
      end

      def clear_cache
        # Cache commands are outgoing only. They wouldn't be passed as a request header.
        # We might however pass them as params so they can survive a redirect.
        if @clear_cache.nil?
          clear_cache_from_params
        else
          @clear_cache
        end
      end

      def clear_cache=(value)
        @clear_cache = value
      end

      def reload_from_time(deprecation: true)
        if deprecation
          ActiveSupport::Deprecation.warn("up.reload_from_time is deprecated. Use conditional GETs instead: https://guides.rubyonrails.org/caching_with_rails.html#conditional-get-support")
        end
        reload_from_time_from_request || if_modified_since
      end

      def reload?(deprecation: true)
        if deprecation
          ActiveSupport::Deprecation.warn("up.reload? is deprecated. Use conditional GETs instead: https://guides.rubyonrails.org/caching_with_rails.html#conditional-get-support")
        end
        !!reload_from_time(deprecation: false)
      end

      def safe_callback(code)
        # Rails 5+
        if (nonce = content_security_policy_nonce.presence)
          "nonce-#{nonce} #{code}"
        else
          code
        end
      end

      private

      attr_reader :controller

      delegate :request, :params, :response, to: :controller

      def if_modified_since
        if (header = request.headers['If-Modified-Since'])
          Time.httpdate(header)
        end
      end

      def content_security_policy_nonce
        controller.send(:content_security_policy_nonce)
      end

      def test_target(frontend_target, tested_target)
        # We must test whether the frontend has passed us a target.
        # The user may have chosen to not reveal their target for better
        # cacheability (see up.network.config#requestMetaKeys).
        if up? && frontend_target.present?
          parts = frontend_target.split(/\s*,\s*/)
          parts.any? do |part|
            if part == tested_target
              true
            elsif part == 'html'
              true
            elsif part == 'body'
              not ['head', 'title', 'meta'].include?(tested_target)
            else
              false
            end
          end
        else
          true
        end
      end

      def fields_as_params
        params = {}
        params[version_param_name]            = serialized_version
        params[target_param_name]             = serialized_target
        params[fail_target_param_name]        = serialized_fail_target
        params[validate_names_param_name]     = serialized_validate_names
        params[mode_param_name]               = serialized_mode
        params[fail_mode_param_name]          = serialized_fail_mode
        params[input_context_param_name]      = serialized_input_context
        params[input_fail_context_param_name] = serialized_input_fail_context
        params[context_changes_param_name]    = serialized_context_changes
        params[events_param_name]             = serialized_events
        params[clear_cache_param_name]        = serialized_clear_cache

        # Don't send empty response headers.
        params = params.select { |_key, value| value.present? }

        params
      end

      def append_params_to_url(url, params)
        if params.blank?
          url
        else
          separator = url.include?('?') ? '&' : '?'
          [url, params.to_query].join(separator)
        end
      end

    end
  end
end
