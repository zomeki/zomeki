# encoding: utf-8
class Cms::Public::OAuthController < ApplicationController
  include Cms::Lib::OAuth

  def dummy
    logger.warn 'Cms::Public::OAuthController#dummy should be intercepted by OmniAuth.'
    redirect_to request.base_url
  end

  def callback
    auth = request.env['omniauth.auth']

    begin
      require 'net/https'
      query = CGI.escape('SELECT name FROM profile WHERE id = me()')
      path  = "/method/fql.query?format=JSON&access_token=#{auth.credentials.token}&query=#{query}"
      https = Net::HTTP.new('api.facebook.com', 443)
      https.use_ssl = true
      auth['info']['name'] = JSON.parse(https.get(path).body).first['name']
    rescue => e
      logger.warn("Give up to get localized user name: #{e.message}")
    end

    user = Cms::OAuthUser.create_or_update_with_omniauth(auth)

    o_auth_session[:user_id] = user.id

    return_to = o_auth_session[:return_to]
    o_auth_session[:return_to] = nil

    redirect_to return_to || request.base_url
  end

  def failure
    redirect_to request.base_url
  end
end
