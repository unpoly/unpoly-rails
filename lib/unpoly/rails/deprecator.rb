module Unpoly
  module Rails

    # Rails 7.2 removed the global ActiveSupport::Deprecation.warn.
    # Since Rails 7.1 each library brings its own deprecator, which our engine
    # registers with the app so that the app's deprecation settings apply.
    def self.deprecator
      @deprecator ||= if ActiveSupport.respond_to?(:deprecator)
        ActiveSupport::Deprecation.new('4.0', 'unpoly-rails')
      else
        # Rails 7.0 and older only have the global deprecator.
        ActiveSupport::Deprecation
      end
    end

  end
end
