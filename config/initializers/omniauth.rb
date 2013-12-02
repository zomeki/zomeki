module OmniAuth
  module Strategies
    class Facebook
      def client
        apps = YAML.load_file(File.join(File.dirname(__FILE__), "#{File.basename(__FILE__, '.*')}_facebook_apps.yml"))

        if (app = apps[request.host])
          options.client_id = app['id']
          options.client_secret = app['secret']
          options[:scope] = app['scope'] if app['scope'].present?
        end

        super
      end
    end
  end
end

OmniAuth.config.path_prefix = '/_auth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
end
