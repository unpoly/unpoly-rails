module Unpoly
  module Rails
    class Engine < ::Rails::Engine
      initializer 'unpoly-rails.assets' do |app|
        # Some projects may choose to completely remove the asset pipeline from the project.
        # In that case the config.assets accessor is not defined.
        asset_pipeline_active = app.config.respond_to?(:assets)

        if asset_pipeline_active
          # The spec folder only exists for local development,
          # it is not shipped with the .gem package.
          spec_folder = root.join('spec')

          # If a local application has referenced the local gem sources
          # (e.g. `gem 'unpoly-rails', path: '../unpoly-rails'`) we use the local build.
          # This way changes from the Webpack watcher are immediately picked
          # up by the application.
          is_local_gem = spec_folder.directory?
          assets_folder = is_local_gem ? 'unpoly-dev' : 'unpoly'

          # Tell the asset pipeline where to find our assets.
          app.config.assets.paths << root.join('assets', assets_folder).to_s
        end
      end
    end
  end
end
