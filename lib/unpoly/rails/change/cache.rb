module Unpoly
  module Rails
    class Change
      class Cache

        def initialize(change)
          @change = change
        end

        # TODO: Docs
        def clear(pattern = '*')
          ActiveSupport::Deprecation.warn("up.cache.clear is deprecated. Use up.cache.expire instead.")
          expire(pattern)
        end

        # TODO: Docs
        def expire(pattern = '*')
          change.expire_cache = pattern
        end

        # TODO: Docs
        def evict(pattern = '*')
          change.evict_cache = pattern
        end

        def keep
          ActiveSupport::Deprecation.warn("up.cache.keep is deprecated. Use up.cache.expire(false) instead.")
          expire(false)
        end

        private

        attr_reader :change

      end
    end
  end
end
