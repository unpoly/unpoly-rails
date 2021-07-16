lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'unpoly/rails/version'
require 'fileutils'

namespace :gem do
  require "bundler/gem_tasks"

  task :explain_frozen_shell do
    puts 'Publishing to rubygems.org. If this seems to freeze, enter your 2FA token.'
  end

  desc "Prompt user to confirm that they're ready"
  task :confirm do
    puts "You are about to release unpoly-rails version #{Unpoly::Rails::VERSION}. Please confirm:"
    puts
    puts "- You have have called `npm run build` in the unpoly repo and saw the build succeed"
    puts "- You have published the unpoly npm package"
    puts "- You have bumped the version in lib/unpoly/rails/version.rb to match that of Unpoly's package.json"
    puts "- You have committed and pushed the changes"
    puts
    puts "Ready to publish? [y/N] "
    reply = STDIN.gets.strip.downcase
    unless reply == 'y'
      puts "Aborted"
      exit
    end
  end

  desc 'Copy symlinked development assets for packaging'
  task :copy_assets do
    Dir['assets/unpoly-dev/*.{css,js}'].each do |path|
      FileUtils.cp path, 'assets/unpoly'
    end
  end


  Rake::Task['gem:release'].enhance ['gem:confirm']
  Rake::Task['gem:build'].enhance ['gem:copy_assets']
  Rake::Task['gem:release:rubygem_push'].enhance ['gem:explain_frozen_shell']

end
