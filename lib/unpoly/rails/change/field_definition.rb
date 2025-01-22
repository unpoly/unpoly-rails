module Unpoly
  module Rails
    class Change
      module FieldDefinition

        def self.included(base)
          base.extend ClassMethods
        end

        # Rails 3.2 delegate generated invalid Ruby with `to: :class`.
        delegate :fields, to: :get_class

        def vary?
          if @vary.nil?
            @vary = true
          end

          @vary
        end

        def vary=(vary)
          @vary = vary
        end

        def no_vary(&block)
          previous_vary = vary?
          self.vary = false
          block.call
        ensure
          self.vary = previous_vary
        end

        private

        def get_class
          self.class
        end

        module ClassMethods

          def field(field, method: nil, response_header_name: nil, request_header_name: nil)
            method ||= field.name

            define_method "#{method}_field" do
              field
            end

            define_method "#{method}_request_header_name" do
              request_header_name || field.header_name
            end

            define_method "#{method}_request_header_accessed!" do
              return unless vary?
              header_name = send("#{method}_request_header_name")
              earlier_varies = response.headers['Vary']&.split(',')&.map(&:strip) || []
              response.headers['Vary'] = (earlier_varies | [header_name]).join(', ')
            end

            define_method "#{method}_response_header_name" do
              response_header_name || field.header_name
            end

            define_method "#{method}_from_request_headers" do
              raw_value = send("raw_#{method}_from_request_headers")
              field.parse(raw_value)
            end

            define_method "raw_#{method}_from_request_headers" do
              header_name = send("#{method}_request_header_name")
              raw_value = request.headers[header_name]
              send("#{method}_request_header_accessed!")
              raw_value
            end

            define_method "#{method}_param_name" do
              field.param_name
            end

            define_method "serialized_#{method}" do
              value = send(method)
              field.stringify(value)
            end

            define_method "raw_#{method}_from_params" do
              params[field.param_name]
            end

            define_method "#{method}_from_params" do
              raw_value = send("raw_#{method}_from_params")
              field.parse(raw_value)
            end

            define_method "#{method}_from_request" do
              raw_value = send("raw_#{method}_from_params") || send("raw_#{method}_from_request_headers")
              field.parse(raw_value)
            end

            define_method "write_#{method}_to_response_headers" do
              value = send(method)
              if Util.blank?(value)
                # Blank values like [] have a present serialization ("[]".present? => true),
                # so we must check the Ruby value here.
                return
              end

              stringified = field.stringify(value)
              if Util.blank?(stringified)
                # App servers don't like blank header values
                return
              end

              header_name = send("#{method}_response_header_name")
              response.headers[header_name] = stringified
            end

          end

        end
      end
    end
  end
end
