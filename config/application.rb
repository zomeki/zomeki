require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module ZomekiCMS
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_attributes = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = :ja

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = (Rails.env != 'production')

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.generators do |g|
      g.test_framework :rspec,
        fixture: true,
        controller_specs: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false
    end

    ##
    require 'rake/dsl_definition'

    Dir::entries("#{Rails.root}/config/modules").each do |mod|
      next if mod =~ /^\./
      file = "#{Rails.root}/config/modules/#{mod}/locales/translation_ja.yml"
      config.i18n.load_path << file if FileTest.exist?(file)
    end

    config.action_view.sanitized_allowed_tags = ActionView::Base.sanitized_allowed_tags | %w(table caption tr th td iframe)
    config.action_view.sanitized_allowed_attributes = ActionView::Base.sanitized_allowed_attributes | %w(style class href src alt title colspan rowspan target id)
  end

  ADMIN_URL_PREFIX = '_system'
end
