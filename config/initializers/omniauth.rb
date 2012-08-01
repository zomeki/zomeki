module OmniAuth
  module Strategies
    class Facebook
      def client
        # https://developers.facebook.com/apps にてアプリを登録
        #
        # apps = {
        #   'サイトURL1' => {id: 'App ID 1', secret: 'App Secret 1'},
        #   'サイトURL2' => {id: 'App ID 2', secret: 'App Secret 2'}
        # }
        apps = {
        }

        if (app = apps["#{request.base_url}/"])
          options.client_id = app[:id]
          options.client_secret = app[:secret]
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
