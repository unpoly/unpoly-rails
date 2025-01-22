module Unpoly
  module Rails
    class Util
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

        def blank?(value)
          value.blank? && value != false
        end

        def present?(value)
          !blank?(value)
        end

      end
    end
  end
end
