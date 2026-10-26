module Unpoly
  module Rails
    class Change
      class Cache

        def initialize(change)
          @change = change
        end

        # TODO: Docs
        def clear(pattern = '*')
          Util.deprecate("up.cache.clear is deprecated. Use up.cache.expire instead.")
          expire(pattern)
        end

        # TODO: Docs
        def expire(pattern = '*')
          if pattern == false
            Util.deprecate("up.cache.expire(false) has no effect. The server can no longer prevent cache expiration.")
          else
            change.expire_cache = pattern
          end
        end

        # TODO: Docs
        def evict(pattern = '*')
          if pattern == false
            Util.deprecate("up.cache.evict(false) has no effect. The server can no longer prevent cache eviction.")
          else
            change.evict_cache = pattern
          end
        end

        def keep
          Util.deprecate("up.cache.keep has no effect. The server can no longer prevent cache expiration.")
        end

        private

        attr_reader :change

      end
    end
  end
end
