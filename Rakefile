module Unpoly
  module Rails
    class Release
      class << self
        def npm_version
          package_json_path = 'assets/unpoly-dev/package.json'
          package_json_content = File.read(package_json_path)
          package_info = JSON.parse(package_json_content)
          package_info['version'].presence or raise Error, "Cannot parse { version } from #{package_json_path}"
        end

        def gem_version
          require_relative 'lib/unpoly/rails/version'
          Unpoly::Rails::VERSION
        end

        def pre_release?
          version =~ /rc|beta|pre|alpha/
        end
      end
    end
  end
end


namespace :gem do
  require "bundler/gem_tasks"

  desc "Prompt user to confirm that they're ready"
  task :confirm do
    puts "You are about to release unpoly-rails version #{Unpoly::Rails::Release.gem_version} to RubyGems:"
    puts
    puts "Before continuing, make sure the following tasks are done:"
    puts
    puts "- The files in ../unpoly/dist are the latest build"
    puts "- You have released a new version of the unpoly npm package"
    puts "- You have bumped the version in lib/unpoly/rails/version.rb to match that of Unpoly's package.json"
    puts "- You have committed and pushed the changes"
    puts
    puts "Continuing will publish a new version to RubyGems."
    puts
    puts "Continue now? [y/N] "
    reply = STDIN.gets.strip.downcase
    unless reply == 'y'
      puts "Aborted."
      exit
    end
  end
  Rake::Task['gem:release'].enhance ['gem:confirm']

  desc 'Ensure that package.js and version.rb have the same version'
  task :ensure_synced_versions do
    gem_version = Unpoly::Rails::Release.gem_version
    npm_version = Unpoly::Rails::Release.npm_version

    unless gem_version == npm_version
      raise "Gem version (#{gem_version}) does not match npm version (#{npm_version})"
    end
  end
  Rake::Task['gem:build'].enhance ['gem:ensure_synced_versions']

  desc 'Copy symlinked development assets for packaging'
  task :copy_assets do
    Dir['assets/unpoly-dev/*.{css,js}'].each do |path|
      FileUtils.cp path, 'assets/unpoly'
    end
  end
  Rake::Task['gem:build'].enhance ['gem:copy_assets']

  task :explain_frozen_shell do
    puts 'Publishing to rubygems.org. If this seems to freeze, enter your 2FA token.'
  end
  Rake::Task['gem:release:rubygem_push'].enhance ['gem:explain_frozen_shell']

end
