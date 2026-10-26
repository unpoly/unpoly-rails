# Changelog

Changes to the unpoly-rails gem. For changes to Unpoly itself, see https://unpoly.com/changes.

Each release also bundles Unpoly's frontend files for the asset pipeline. If your app installs Unpoly from npm, only the server-side changes matter to you, and any recent gem version will do.


## 3.15.0

- Bundles Unpoly 3.15.0 for the asset pipeline.
- `up.layer.open` converts snake_case option names to Unpoly's camelCase names, e.g. `:on_accepted_reload` becomes `onAcceptedReload`. Keys inside the `:context` option are passed through unchanged.
- Fix Unpoly params being lost when redirecting to a URL with a `#hash`. The params were appended after the hash, so changes like a new target, events or context changes did not survive the redirect.
- A `#hash` in a redirect URL is kept for fragment updates, e.g. `redirect_to post_path(@post, anchor: 'comments')`. The gem passes it as a `_up_location_hash` param and echoes it in the [`X-Up-Location`](https://unpoly.com/api/X-Up-Location) header after the redirect. Unpoly then reveals the element with that ID and shows the `#hash` in the address bar. Requires Unpoly 3.15 or later.
- The gem now includes source maps for the bundled frontend files.
- The gem's metadata links to unpoly.com, the changelog, the source code and the issue tracker.
- Fix deprecated helpers like `up.cache.clear` or `up.render_nothing` raising a `NoMethodError` on Rails 7.2+. On Rails 7.1+, the gem's deprecation warnings now follow your app's deprecation settings.


## 3.14.3

- Bundles Unpoly 3.14.3 for the asset pipeline.


## 3.14.2

- Bundles Unpoly 3.14.2 for the asset pipeline.


## 3.14.1

- Bundles Unpoly 3.14.1 for the asset pipeline.


## 3.14.0

- Bundles Unpoly 3.14.0 for the asset pipeline.


## 3.12.0

- Bundles Unpoly 3.12.0 for the asset pipeline.


## 3.11.0

- New `up.layer.open` renders the response in a new overlay, using an [`X-Up-Open-Layer`](https://unpoly.com/api/X-Up-Open-Layer) header. Overlay options like `mode: 'drawer'` can be passed as keyword arguments.
- New `up.origin_layer.mode`, `up.origin_layer.root?` and `up.origin_layer.overlay?` tell you about the layer that caused the request, using the [`X-Up-Origin-Mode`](https://unpoly.com/api/X-Up-Origin-Mode) header.
- `up.cache.keep`, `up.cache.expire(false)` and `up.cache.evict(false)` no longer set a response header and print a deprecation warning. The server can no longer prevent the client-side cache from being expired or evicted.
- Bundles Unpoly 3.11.0 for the asset pipeline.


## 3.10.2

- Bundles Unpoly 3.10.2 for the asset pipeline.


## 3.10.0

- No longer send empty response headers like `X-Up-Events: []`.
- When redirecting, no longer add empty params like `_up_context_changes=%7B%7D` or `_up_events=%5B%5D` to the redirect URL.
- Bundles Unpoly 3.10.0 for the asset pipeline.


## 3.9.5

- Bundles Unpoly 3.9.5 for the asset pipeline.


## 3.9.3.1

- Preserve an `X-Up-Target` changed by the server through a redirect. The original target, which the browser re-sends with the redirected request, no longer overrides it.


## 3.9.3

- Bundles Unpoly 3.9.3 for the asset pipeline.


## 3.9.2.1

- Ignore nested values in `_up_*` params (e.g. `_up_context_changes[foo]=bar`) instead of raising an error. These are often sent by security scanners. The value is logged as an error.


## 3.9.2

- Bundles Unpoly 3.9.2 for the asset pipeline.


## 3.9.1

- Bundles Unpoly 3.9.1 for the asset pipeline.


## 3.9.0

- Bundles Unpoly 3.9.0 for the asset pipeline.


## 3.8.0.1

- Loading the gem no longer loads `ActionController::Base` early, before your app's configuration is applied. The controller extensions are now added with `ActiveSupport.on_load(:action_controller_base)`.


## 3.8.0

- Bundles Unpoly 3.8.0 for the asset pipeline.


## 3.7.3.2

- `up.target?` now returns `true` for optional targets, e.g. when the request targets `#foo:maybe` and you test for `#foo`.


## 3.7.3.1

- When an `X-Up-*` header that should contain a JSON object contains another JSON value (like an array or a string), log an error and use an empty hash.


## 3.7.3

- Bundles Unpoly 3.7.3 for the asset pipeline.


## 3.7.2

- Bundles Unpoly 3.7.2 for the asset pipeline.


## 3.7.1

- Bundles Unpoly 3.7.1 for the asset pipeline.


## 3.7.0.1

- Re-release of 3.7.0 without changes, to make RubyGems redistribute the gem.


## 3.7.0

- Bundles Unpoly 3.7.0 for the asset pipeline.


## 3.6.1.1

- Parse `X-Up-Target` and `Vary` headers without a regular expression that could be slow for long header values.


## 3.6.1

- Bundles Unpoly 3.6.1 for the asset pipeline.


## 3.6.0

- Fix an error for requests whose URL contains `_up_` in its path, but has no query string.
- Bundles Unpoly 3.6.0 for the asset pipeline.


## 3.5.2

- Bundles Unpoly 3.5.2 for the asset pipeline.


## 3.5.1

- Bundles Unpoly 3.5.1 for the asset pipeline.


## 3.5.0

- Bundles Unpoly 3.5.0 for the asset pipeline.


## 3.3.0.1

- Malformed JSON in `X-Up-*` headers no longer raises an error. It is logged as an error and ignored. Security scanners often send such headers.


## 3.3.0

- Bundles Unpoly 3.3.0 for the asset pipeline.


## 3.2.2.1

- New `up.validate_name?('email')` tests whether a given field is being [validated](https://unpoly.com/api/X-Up-Validate).
- Fix `up.validate_name` raising a `NameError` (broken since 3.0.0).


## 3.2.2

- Bundles Unpoly 3.2.2 for the asset pipeline.


## 3.2.1

- Bundles Unpoly 3.2.1 for the asset pipeline.


## 3.2.0

- Bundles Unpoly 3.2.0 for the asset pipeline.


## 3.1.1

- Bundles Unpoly 3.1.1 for the asset pipeline.


## 3.1.0

- Bundles Unpoly 3.1.0 for the asset pipeline.


## 3.0.0

- New `up.validate_names` returns the names of all fields that triggered a [validation](https://unpoly.com/api/X-Up-Validate). Unpoly 3 may batch multiple validations into a single request.
- Removed `up.validate`. Use `up.validate_name` or `up.validate_names` instead.
- New `up.cache.expire` and `up.cache.evict` control the client-side cache, using the [`X-Up-Expire-Cache`](https://unpoly.com/api/X-Up-Expire-Cache) and [`X-Up-Evict-Cache`](https://unpoly.com/api/X-Up-Evict-Cache) headers. Expired pages can still be rendered and are then revalidated. Evicted pages are erased from the cache.
- Deprecated `up.cache.clear`. Use `up.cache.expire` instead.
- Deprecated `up.cache.keep`. Use `up.cache.expire(false)` instead.
- Reading an Unpoly request header through a helper like `up.target` or `up.layer.mode` now adds that header to the `Vary` response header. To read a header without setting `Vary`, e.g. for logging, wrap your code in an `up.no_vary { ... }` block.
- Deprecated `up.render_nothing`. Use `head(:no_content)` instead. `up.render_nothing` now responds with `204 No Content` by default.
- Deprecated `up.reload?` and `up.reload_from_time`. Unpoly sends standard `If-Modified-Since` and `If-None-Match` headers when reloading a fragment, so you can use Rails' conditional GET helpers like `fresh_when` or `stale?`.
- `X-Up-Title` is now sent as a JSON-encoded string, so non-ASCII characters can be escaped.
- When redirecting, only headers set by the server (like events, context changes, cache commands or a changed target) are preserved as `_up_*` params. Request headers set by Unpoly are re-sent by the browser.
- Includes the fixes from 2.7.1.1 to 2.7.2.2.
- Bundles Unpoly 3.0.0 for the asset pipeline.


## 2.7.2.2

- Only send an `X-Up-Location` header when the request URL contains `_up_*` params that must be removed.


## 2.7.2.1

- Escape non-ASCII characters in JSON response headers like `X-Up-Events`, `X-Up-Context` or `X-Up-Accept-Layer`, so they can be transported over HTTP.


## 2.7.2

- Bundles Unpoly 2.7.2 for the asset pipeline.


## 2.7.1.1

- Fix the serialization of array params (like `ids[]=1&ids[]=2`) in the `X-Up-Location` header.


## 2.7.1

- Bundles Unpoly 2.7.1 for the asset pipeline.


## 2.7.0

- Bundles Unpoly 2.7.0 for the asset pipeline.


## 2.6.1

- Bundles Unpoly 2.6.1 for the asset pipeline.


## 2.6.0

- Bundles Unpoly 2.6.0 for the asset pipeline.


## 2.5.3

- Bundles Unpoly 2.5.3 for the asset pipeline.


## 2.5.2

- Bundles Unpoly 2.5.2 for the asset pipeline.


## 2.5.1

- Bundles Unpoly 2.5.1 for the asset pipeline.


## 2.5.0

- Bundles Unpoly 2.5.0 for the asset pipeline.


## 2.4.1

- Bundles Unpoly 2.4.1 for the asset pipeline.


## 2.4.0

- Bundles Unpoly 2.4.0 for the asset pipeline.


## 2.3.0

- New `up.safe_callback` helper prefixes a JavaScript callback with the response's CSP nonce. This lets callback attributes like `[up-on-loaded]` run with a [strict Content Security Policy](https://unpoly.com/learn/script-security).
- Bundles Unpoly 2.3.0 for the asset pipeline.


## 2.2.1

- Bundles Unpoly 2.2.1 for the asset pipeline.


## 2.2.0

- First release from the separate unpoly-rails repository.
- Supports Rails 3.2 again. Version 2.1.0 required Rails 4.2.
- Bundles Unpoly 2.2.0 for the asset pipeline.
