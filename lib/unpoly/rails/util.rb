require 'active_support/core_ext/enumerable'

module Unpoly
  module Rails
    class Util

      # Unpoly writes acronyms in uppercase when they don't start a name,
      # e.g. dismissARIALabel or normalizeURL.
      ACRONYMS = %w[ARIA URL HTML JSON ID].index_by(&:downcase)

      class << self

        def guard_json_decode(raw, &default)
          if raw.present?
            if raw.is_a?(String)
              begin
                ActiveSupport::JSON.decode(raw)
              rescue ActiveSupport::JSON.parse_error
                # We would love to crash here, as it might indicate a bug in the frontend code.
                # Unfortunately security scanners may be spamming malformed JSON in X-Up headers,
                # DOSing us with error notifications.
                ::Rails.logger.error('unpoly-rails: Ignoring malformed JSON in X-Up header')
                default&.call
              end
            else
              # Security spammers may pass nested param values in params like _up_context_changes.
              ::Rails.logger.error('unpoly-rails: Ignoring nested value in _up param')
              default&.call
            end
          else
            default&.call
          end
        end

        # We build a lot of JSON that goes into HTTP header.
        # High-ascii characters are not safe to transport over HTTP, but we
        # can use JSON escape sequences (\u0012) to make them low-ascii.
        def safe_json_encode(value)
          json = ActiveSupport::JSON.encode(value)
          escape_non_ascii(json)
        end

        def escape_non_ascii(unicode_string)
          unicode_string.gsub(/[[:^ascii:]]/) { |char| "\\u" + char.ord.to_s(16).rjust(4, "0") }
        end

        # Percent-encodes all characters that are not allowed in a URL's #hash (RFC 3986).
        # Existing escape sequences like %20 are kept.
        def escape_url_fragment(fragment)
          fragment.gsub(%r{[^A-Za-z0-9\-._~!$&'()*+,;=:@/?%]}) do |char|
            char.bytes.map { |byte| '%%%02X' % byte }.join
          end
        end

        # Converts a snake_case option name like :on_accepted_reload to Unpoly's
        # camelCase name like "onAcceptedReload". Names that are already camelCased
        # are kept unchanged.
        #
        # We don't use ActiveSupport's #camelize, so the app's inflections don't apply.
        def camelize_option_name(name)
          name.to_s.gsub(/_([a-z\d]+)/) { ACRONYMS[$1] || $1.capitalize }
        end

        def blank?(value)
          value.blank? && value != false
        end

        def present?(value)
          !blank?(value)
        end

        # Rails 7.1+ gives each library its own deprecator, which the engine registers with the app.
        # Rails 7.0 and older only have the global one.
        def deprecator
          @deprecator ||= if ActiveSupport.respond_to?(:deprecator)
            ActiveSupport::Deprecation.new('4.0', 'unpoly-rails')
          else
            ActiveSupport::Deprecation
          end
        end

        def deprecate(message)
          deprecator.warn(message)
        end

      end
    end
  end
end
