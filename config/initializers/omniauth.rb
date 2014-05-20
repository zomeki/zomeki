module OmniAuth
  module Strategies
    class Facebook
      def client
        begin
          apps = YAML.load_file(Rails.root.join('config/sns_apps.yml'))['facebook']
          if (app = apps[request.host])
            options.client_id = app['id']
            options.client_secret = app['secret']
            options[:scope] = app['scope'] if app['scope'].present?
          end
        rescue => e
          warn_log "#{__FILE__}:#{__LINE__}:#{e.message}"
        end

        super
      end
    end

    class Twitter
      def consumer
        begin
          apps = YAML.load_file(Rails.root.join('config/sns_apps.yml'))['twitter']
          if (app = apps[request.host])
            options.consumer_key = app['key']
            options.consumer_secret = app['secret']
          end
        rescue => e
          warn_log "#{__FILE__}:#{__LINE__}:#{e.message}"
        end

        super
      end
    end
  end
end

OmniAuth.config.path_prefix = '/_auth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
end
