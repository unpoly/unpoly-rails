module Unpoly
  module Rails
    class Change

      class Field
        PARAM_PREFIX = '_up_'

        def initialize(name)
          @name = name
        end

        attr_reader :name

        def header_name
          result = name.to_s
          result = result.capitalize
          result = result.gsub(/_(.)/) { "-#{$1.upcase}" }
          result = "X-Up-#{result}"
          result
        end

        def param_name
          "#{PARAM_PREFIX}#{name}"
        end

        def parse(raw)
          raise NotImplementedError
        end

        def stringify(value)
          raise NotImplementedError
        end

        ##
        # A string value, serialized as itself.
        class String < Field

          def parse(raw)
            raw
          end

          def stringify(value)
            unless value.nil?
              value.to_s
            end
          end

        end

        ##
        # An array of strings, separated by a space character.
        class SeparatedValues < Field

          def initialize(name, separator: ' ', default: nil)
            super(name)
            @separator = separator
            @default = default
          end

          def parse(raw)
            if raw
              raw.split(@separator)
            else
              @default&.call
            end
          end

          def stringify(value)
            unless value.nil?
              value.join(@separator)
            end
          end

        end

        ##
        # A date and time value, serialized as the number of seconds since the epoch.
        class Time < Field

          def parse(raw)
            if raw.present?
              ::Time.at(raw.to_i)
            end
          end

          def stringify(value)
            unless value.nil?
              value.to_i
            end
          end

        end

        ##
        # A hash of values, serialized as JSON.
        class Hash < Field

          def initialize(name, default: nil)
            super(name)
            @default = default
          end

          def parse(raw)
            result = Util.guard_json_decode(raw, &@default)

            if result.is_a?(::Hash)
              result = ActiveSupport::HashWithIndifferentAccess.new(result)
            end

            result
          end

          def stringify(value)
            unless value.nil?
              Util.safe_json_encode(value)
            end
          end

        end

        ##
        # An array of values, serialized as JSON.
        class Array < Field

          def initialize(name, default: nil)
            super(name)
            @default = default
          end

          def parse(raw)
            Util.guard_json_decode(raw, &@default)
          end

          def stringify(value)
            unless value.nil?
              Util.safe_json_encode(value)
            end
          end

        end

      end
    end
  end
end
