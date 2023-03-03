module Unpoly
  module Rails
    class Util
      class << self

        def json_decode(string)
          ActiveSupport::JSON.decode(string)
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

      end
    end
  end
end
