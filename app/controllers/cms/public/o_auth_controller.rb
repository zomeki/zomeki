# encoding: utf-8
class Cms::Public::OAuthController < ApplicationController
  include Cms::Lib::OAuth

  def dummy
    warn_log 'Cms::Public::OAuthController#dummy should be intercepted by OmniAuth.'
    redirect_to request.base_url
  end

  def callback
    oa_params = request.env['omniauth.params']
    oa_auth = request.env['omniauth.auth']

    case oa_auth[:provider]
    when 'facebook'
      auth = {provider:         oa_auth['provider'],
              uid:              oa_auth['uid'],
              info_nickname:    oa_auth['info']['nickname'],
              info_name:        '',
              info_image:       oa_auth['info']['image'],
              info_url:         oa_auth['info']['urls'].try('[]', 'Facebook').to_s,
              token:            oa_auth.credentials.token,
              token_expires_at: oa_auth.credentials.expires_at}

      begin
        require 'net/https'
        query = CGI.escape('SELECT name FROM profile WHERE id = me()')
        path  = "/method/fql.query?format=JSON&access_token=#{oa_auth.credentials.token}&query=#{query}"
        https = Net::HTTP.new('api.facebook.com', 443)
        https.use_ssl = true
        auth[:info_name] = JSON.parse(https.get(path).body).first['name'].to_s
      rescue => e
        warn_log "Failed to get localized user name: #{e.message}"
      end

      if oa_params.empty?
        user = Cms::OAuthUser.create_or_update_with_omniauth(auth)

        o_auth_session[:user_id] = user.id

        return_to = o_auth_session[:return_to]
        o_auth_session[:return_to] = nil

        return redirect_to(return_to || request.base_url)
      else
        if oa_params['class'].present? && oa_params['id'].present? && oa_params['return_to'].present?
          item = oa_params['class'].constantize.find(oa_params['id'])

          item.update_attributes(auth)

          return redirect_to(oa_params['return_to'])
        else
          return redirect_to(request.base_url)
        end
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
