# encoding: utf-8
class Cms::Public::OAuthController < ApplicationController
  include Cms::Lib::OAuth

  def dummy
    warn_log 'Cms::Public::OAuthController#dummy should be intercepted by OmniAuth.'
    redirect_to request.base_url
  end

  def callback
    omniauth_params = request.env['omniauth.params']
    omniauth_auth = request.env['omniauth.auth']

    case omniauth_auth[:provider]
    when 'facebook'
      if omniauth_params.empty?
        auth = {provider:      omniauth_auth['provider'],
                uid:           omniauth_auth['uid'],
                info_nickname: omniauth_auth['info']['nickname'],
                info_name:     '',
                info_image:    omniauth_auth['info']['image'],
                info_url:      omniauth_auth['info']['urls'].try('[]', 'Facebook') || ''}

        begin
          require 'net/https'
          query = CGI.escape('SELECT name FROM profile WHERE id = me()')
          path  = "/method/fql.query?format=JSON&access_token=#{omniauth_auth.credentials.token}&query=#{query}"
          https = Net::HTTP.new('api.facebook.com', 443)
          https.use_ssl = true
          auth[:info_name] = JSON.parse(https.get(path).body).first['name'].presence || ''
        rescue => e
          warn_log "Failed to get localized user name: #{e.message}"
        end

        user = Cms::OAuthUser.create_or_update_with_omniauth(auth)

        o_auth_session[:user_id] = user.id

        return_to = o_auth_session[:return_to]
        o_auth_session[:return_to] = nil

        return redirect_to(return_to || request.base_url)
      else
        info_log omniauth_params.inspect
      end
    else
      warn_log "Unknown provider: #{auth[:provider]}"
    end
  end

  def failure
    warn_log params.inspect
    redirect_to request.base_url
  end
end
