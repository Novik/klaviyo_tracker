module KlaviyoTracker
  class InstallGenerator < Rails::Generators::Base

    source_root File.expand_path("../templates", __FILE__)

    def add_files
      template 'klaviyo_tracker.rb', 'config/initializers/klaviyo_tracker.rb'
    end

  end
end
