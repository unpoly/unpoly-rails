unpoly-rails: Ruby on Rails bindings for Unpoly
===============================================

[Unpoly](https://unpoly.com) is an [unobtrusive JavaScript](https://en.wikipedia.org/wiki/Unobtrusive_JavaScript) framework for server-side web applications.

The `unpoly-rails` gem helps integrating Unpoly with [Ruby on Rails](https://rubyonrails.org/) applications.

This branch tracks the next major version, Unpoly **3.x**.\
If you're using Unpoly **2.x**, use the [`2.x-stable`](https://github.com/unpoly/unpoly-rails/tree/2.x-stable) branch.\
If you're using Unpoly **1.x** or **0.x**, use the [`1.x-stable`](https://github.com/unpoly/unpoly/tree/1.x-stable) branch in the [`unpoly`](https://github.com/unpoly/unpoly-rails/tree/2.x-stable) repository.\


Installing the gem
------------------

Add the following line to your `Gemfile`:

```ruby
gem 'unpoly-rails'
```

Now run `bundle install` and restart your development server.


Installing frontend assets
--------------------------

### With esbuild or Webpacker

If you're using [esbuild](https://esbuild.github.io/) or [Webpacker](https://edgeguides.rubyonrails.org/webpacker.html), install the [`unpoly` npm package](https://unpoly.com/install/npm) to get Unpoly's frontend files.

Now `import` Unpoly from your `application.js` pack:

```js
import 'unpoly/unpoly.js'
import 'unpoly/unpoly.css'
```

You may need to import [additional files](https://unpoly.com/install), e.g. when migrating from an old Unpoly version.


### With the Asset Pipeline

If you're using the [Asset Pipeline](https://guides.rubyonrails.org/asset_pipeline.html), this `unpoly-rails` gem also contains Unpoly's frontend files. The files are automatically added to the Asset Pipeline's <a href="https://guides.rubyonrails.org/asset_pipeline.html#search-paths">search path</a>.

Add the following line to your `application.js` manifest:

```js
//= require unpoly
```

Also add the following line to your `application.css` manifest:

```css
/*
 *= require unpoly
 */
```

You may need to require [additional files](https://unpoly.com/install), e.g. when migrating from an old Unpoly version.


Server protocol helpers
-----------------------

This `unpoly-rails` gem implements the <a href="https://unpoly.com/up.protocol">optional server protocol</a> by providing the following helper methods to your controllers, views and helpers.


### Detecting a fragment update

Use `up?` to test whether the current request is a [fragment update](https://unpoly.com/up.link):

```ruby
up? # => true or false
```

To retrieve the CSS selector that is being [updated](https://unpoly.com/up.link), use `up.target`:

```ruby
up.target # => '.content'
```

The Unpoly frontend will expect an HTML response containing an element that matches this selector. Your Rails app is free to render a smaller response that only contains HTML matching the targeted selector. You may call `up.target?` to test whether a given CSS selector has been targeted:

```ruby
if up.target?('.sidebar')
  render('expensive_sidebar_partial')
end
```

Fragment updates may target different selectors for successful (HTTP status `200 OK`) and failed (status `4xx` or `5xx`) responses.
Use these methods to inspect the target for failed responses:

- `up.fail_target`: The CSS selector targeted for a failed response
- `up.fail_target?(selector)`: Whether the given selector is targeted for a failed response
- `up.any_target?(selector)`: Whether the given selector is targeted for either a successful or a failed response

### Changing the render target

The server may instruct the frontend to render a different target by assigning a new CSS selector to the `up.target` property:

```ruby
unless signed_in?
  up.target = 'body'
  render 'sign_in'
end
```

The frontend will use the server-provided target for both successful (HTTP status `200 OK`) and failed (status `4xx` or `5xx`) responses.


### Rendering nothing

Sometimes it's OK to render nothing, e.g. when you know that the current layer is to be closed.

In this case use `head(:no_content)`:

```ruby
class NotesController < ApplicationController
  def create
    @note = Note.new(note_params)
    if @note.save
      if up.layer.overlay?
        up.accept_layer(@note.id)
        head :no_content
      else
        redirect_to @note
      end
    end
  end
end
```


### Pushing a document title to the client

To force Unpoly to set a document title when processing the response:

```ruby
up.title = 'Title from server'
```

This is useful when you skip rendering the `<head>` in an Unpoly request.

### Emitting events on the frontend

You may use `up.emit` to emit an event on the `document` after the
fragment was updated:

```ruby
class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    up.emit('user:selected', id: @user.id)
  end

end
```

If you wish to emit an event on the current [layer](https://unpoly.com/up.layer)
instead of the `document`, use `up.layer.emit`:

```ruby
class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    up.layer.emit('user:selected', id: @user.id)
  end

end
```

### Detecting an Unpoly form validation

To test whether the current request is a [form validation](https://unpoly.com/input-up-validate):

```ruby
up.validate?
```

When detecting a validation request, the server is expected to validate (but not save) the form submission and render a new copy of the form with validation errors. A typical saving action should behave like this:

```ruby
class UsersController < ApplicationController

  def create
    user_params = params[:user].permit(:email, :password)
    @user = User.new(user_params)
    if up.validate?
      @user.valid?  # run validations, but don't save to the database
      render 'form' # render form with error messages
    elsif @user.save?
      sign_in @user
    else
      render 'form', status: :bad_request
    end
  end

end
```

You may also access the [names of the fields that triggered the validation request](https://unpoly.com/X-Up-Validate):

```ruby
up.validate_names # => ['email', 'password']
```


### Detecting a fragment reload

When Unpoly [reloads](https://unpoly.com/up.reload) or [polls](https://unpoly.com/up-poll) a fragment, the server will often render the same HTML. You can configure your controller actions to only render HTML if the underlying content changed since an earlier request.

Only rendering when needed saves <b>CPU time</b> on your server, which spends most of its response time rendering HTML. This also reduces the <b>bandwidth cost</b> for a request/response exchange to **~1 KB**.

When a fragment is reloaded, Unpoly sends an [`If-Modified-Since`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Modified-Since) request header with the fragment's earlier [`Last-Modified`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Last-Modified) time. It also sends an [`If-None-Match`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-None-Match) header with the fragment's earlier [`ETag`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag).

Rails' [conditional GET support](https://guides.rubyonrails.org/caching_with_rails.html#conditional-get-support) lets you compare and set modification times and ETags with methods like `#fresh_when` or `#stale?`:

```ruby
class MessagesController < ApplicationController

  def index
    @messages = current_user.messages.order(time: :desc)

    # If the request's ETag and last modification time matches the given `@messages`,
    # does not render and send a a `304 Not Modified` response.
    # If the request's ETag or last modification time does not match, we will render
    # the `index` view with fresh `ETag` and `Last-Modified` headers.
    fresh_when(@messages)
  end

end
```



### Allowing callbacks with a strict CSP

When your Content Security Policy disallows `eval()`, Unpoly cannot directly run callbacks HTML attributes. This affects `[up-]` attributes like `[up-on-loaded]` or `[up-on-accepted]`. See [Unpoly's CSP guide](https://unpoly.com/csp) for details.

The following callback would crash the fragment update with an error like `Uncaught EvalError: call to Function() blocked by CSP`:

```ruby
link_to 'Click me', '/path, 'up-follow': true, 'up-on-loaded': "alert()"
```

Unpoly lets your work around this by prefixing your callback with your response's [CSP nonce](https://content-security-policy.com/nonce/):

```ruby
link_to 'Click me', '/path', 'up-follow': true, 'up-on-loaded': 'nonce-kO52Iphm8BAVrcdGcNYjIA== alert()')
```

To keep your callbacks compact, you may use the `up.safe_callback` helper for this:

```ruby
link_to 'Click me', '/path, 'up-follow': true, 'up-on-loaded': up.safe_callback("alert()")
```

For this to work you must also include the `<meta name="csp-nonce">` tag in the `<head>` of your initial page. Rails has a [`csp_meta_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/CspHelper.html#method-i-csp_meta_tag) helper for that purpose.


### Working with context

Calling `up.context` will return the [context](https://unpoly.com/up.context) object of the targeted layer.

The context is a JSON object shared between the frontend and the server.
It persists for a series of Unpoly navigation, but is cleared when the user makes a full page load.
Different Unpoly [layers](https://unpoly.com/up.layer) will usually have separate context objects,
although layers may choose to share their context scope. 

You may read and change the context object. Changes will be sent to the frontend with your response.

```ruby
class GamesController < ApplicationController

  def restart
    up.context[:lives] = 3
    render 'stage1'
  end

end
```

Keys can be accessed as either strings or symbols:

```ruby
puts "You have " + up.layer.context[:lives] + " lives left"
puts "You have " + up.layer.context['lives'] + " lives left"
````

You may delete a key from the frontend by calling `up.context.delete`:

```ruby
up.context.delete(:foo)
````

You may replace the entire context by calling `up.context.replace`: 

```ruby
context_from_file = JSON.parse(File.read('context.json))
up.context.replace(context_from_file)
```

`up.context` is an alias for `up.layer.context`.


### Accessing the targeted layer

Use the methods below to interact with the [layer](/up.layer) of the fragment being targeted.

Note that fragment updates may target different layers for successful (HTTP status `200 OK`) and failed (status `4xx` or `5xx`) responses.

#### `up.layer.mode`

Returns the [mode](https://unpoly.com/up.layer.mode) of the targeted layer (e.g. `"root"` or `"modal"`).

#### `up.layer.root?`

Returns whether the targeted layer is the root layer.

#### `up.layer.overlay?`

Returns whether the targeted layer is an overlay (not the root layer).

#### `up.layer.context`

Returns the [context](https://unpoly.com/up.context) object of the targeted layer.
See documentation for `up.context`, which is an alias for `up.layer.context`.

#### `up.layer.accept(value)`

[Accepts](https://unpoly.com/up.layer.accept) the current overlay.

Does nothing if the root layer is targeted.

Note that Rails expects every controller action to render or redirect.
Your action should either call `up.render_nothing` or respond with `text/html` content matching the requested target.

#### `up.layer.dismiss(value)`

[Dismisses](https://unpoly.com/up.layer.dismisses) the current overlay.

Does nothing if the root layer is targeted.

Note that Rails expects every controller action to render or redirect.
Your action should either call `up.render_nothing` or respond with `text/html` content matching the requested target.

#### `up.layer.emit(type, options)`

[Emits an event](https://unpoly.com/up.layer.emit) on the targeted layer.

#### `up.fail_layer.mode`

Returns the [mode](https://unpoly.com/up.layer.mode) of the layer targeted for a failed response.

#### `up.fail_layer.root?`

Returns whether the layer targeted for a failed response is the root layer.

#### `up.fail_layer.overlay?`

Returns whether the layer targeted for a failed response is an overlay.

#### `up.fail_layer.context`

Returns the [context](https://unpoly.com/up.context) object of the layer targeted for a failed response.


### Expiring the client-side cache

The Unpoly frontend [caches server responses](https://unpoly.com/caching) for a few minutes, making requests to these URLs return instantly.
Only `GET` requests are cached. The entire cache is expired after every non-`GET` request (like `POST` or `PUT`).

The server may override these defaults. For instance, the server can expire Unpoly's client-side response cache, even for `GET` requests:

```ruby
up.cache.expire
```

You may also expire a single URL or [URL pattern](https://unpoly.com/url-patterns):

```ruby
up.cache.expire('/notes/*')
```

You may also prevent cache expiration for an unsafe request:

```ruby
up.cache.expire(false)
```

Here is an longer example where the server uses careful cache management to avoid expiring too much of the client-side cache:

```ruby
def NotesController < ApplicationController

  def create
    @note = Note.create!(params[:note].permit(...))
    if @note.save
      up.cache.expire('/notes/*') # Only expire affected entries
      redirect_to(@note)
    else
      up.cache.expire(false) # Keep the cache fresh because we haven't saved
      render 'new'
    end
  end
  ...
end
```

### Evicting pages from the client-side cache

Instead of *expiring* pages from the cache you may also *evict*. The difference is that expired pages can still be rendered instantly and are then [revalidated](/caching#revalidation) with the server. Evicted pages are erased from the cache.

You may also expire all entries matching an [URL pattern](https://unpoly.com/url-patterns):

To evict the entire client-side cache:

```ruby
up.cache.evict
```

You may also evict a single URL or [URL pattern](https://unpoly.com/url-patterns):

```ruby
up.cache.evict('/notes/*')
```


### Unpoly headers are preserved through redirects

`unpoly-rails` patches [`redirect_to`](https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to)
so [Unpoly-related request and response headers](https://unpoly.com/up.protocol) are preserved for the action you redirect to.


### Accessing Unpoly request headers automatically sets a `Vary` response header

Accessing [Unpoly-related request headers](https://unpoly.com/up.protocol) through helper methods like `up.target` will automatically add a [`Vary`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Vary) response header. This is to indicate that the request header influenced the response and the response should be cached separately for each request header value.

For example, a controller may access the request's `X-Up-Mode` through the `up.layer.mode` helper:

```ruby
def create
  # ...

  if up.layer.mode == 'modal' # Sets Vary header
    up.layer.accept
  else
    redirect_to :show
  end
end
```

`unpoly-rails` will automatically add a `Vary` header to the response:

```http
Vary: X-Up-Mode
```

There are cases when reading an Unpoly request header does not necessarily influence the response, e.g. for logging. In that cases no `Vary` header should be set. To do so, call the helper method inside an `up.no_vary` block:

```ruby
up.no_vary do
  Rails.logger.info("Unpoly mode is " + up.layer.mode.inspect) # No Vary header is set
end
````

Note that accessing `response.headers[]` directly never sets a `Vary` header:

```ruby
Rails.logger.info("Unpoly mode is " + response.headers['X-Up-Mode']) # No Vary header is set
```


### Automatic redirect detection

`unpoly-rails` installs a [`before_action`](https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action) into all controllers which echoes the request's URL as a response header `X-Up-Location` and the request's
HTTP method as `X-Up-Method`.


### Automatic method detection for initial page load

`unpoly-rails` sets an `_up_method` cookie that Unpoly needs to detect the request method for the initial page load.

If the initial page was loaded with a non-`GET` HTTP method, Unpoly will fall back to full page loads for all actions that require `pushState`.

The reason for this is that some browsers remember the method of the initial page load and don't let the application change it, even with `pushState`. Thus, when the user reloads the page much later, an affected browser might request a `POST`, `PUT`, etc. instead of the correct method.


What you still need to do manually
----------------------------------

### Failed form submissions must return a non-200 status code

Unpoly lets you submit forms via AJAX by using the [`form[up-follow]`](https://unpoly.com/form-up-submit) selector or [`up.submit()`](https://unpoly.com/up.submit) function.

For Unpoly to be able to detect a failed form submission,
the form must be re-rendered with a non-200 HTTP status code.
We recommend to use either 400 (bad request) or 422 (unprocessable entity).

To do so in Rails, pass a [`:status` option to `render`](http://guides.rubyonrails.org/layouts_and_rendering.html#the-status-option):

```ruby
class UsersController < ApplicationController

  def create
    user_params = params[:user].permit(:email, :password)
    @user = User.new(user_params)
    if @user.save?
      sign_in @user
    else
      render 'form', status: :bad_request
    end
  end

end
```

Development
-----------

### Before you make a PR

Before you create a pull request, please have some discussion about the proposed change by [opening an issue on GitHub](https://github.com/unpoly/unpoly/issues/new).

### Running tests

- Install the Ruby version from `.ruby-version` (currently 2.3.8)
- Install Bundler by running `gem install bundler`
- Install dependencies by running `bundle install`
- Run `bundle exec rspec`

The tests run against a minimal Rails app that lives in `spec/dummy`.

### Making a new release

Install the `unpoly-rails` and [`unpoly`](https://github.com/unpoly/unpoly) repositories into the same parent folder:

```
projects/
  unpoly/
  unpoly-rails/
```

During development `unpoly-rails` will use assets from the folder `assets/unpoly-dev`, which is symlinked against the `dist` folder of the ``unpoly` repo.

Before packaging the gem, a rake task will copy symlinked files `assets/unpoly-dev/*` to `assets/unpoly/*`. The latter is packaged into the gem and distributed.

```
projects/
  unpoly/
    dist/
      unpoly.js
      unpoly.css
  unpoly-rails
    assets/
      unpoly-dev   -> ../../unpoly/dist
        unpoly.js  -> ../../unpoly/dist/unpoly.js
        unpoly.css -> ../../unpoly/dist/unpoly.css
      unpoly
        unpoly.js
        unpoly.css
```

Making a new release of `unpoly-rails` involves the following steps:

- Make a new build of unpoly (`npm run build`)
- Make a new release of the unpoly npm package
- Bump the version in `lib/unpoly/rails/version.rb` to match that in Unpoly's `package.json`
- Commit and push the changes
- Run `rake gem:release`
