# encoding: utf-8
module Cms::Lib::OAuth
  extend ActiveSupport::Concern

  included do
    helper_method :o_auth_session, :current_o_auth_user, :o_auth_user_logged_in?
  end

  protected

  def o_auth_session
    session[:o_auth] ||= {}
  end

  def current_o_auth_user
    @current_o_auth_user ||= Cms::OAuthUser.find_by_id(o_auth_session[:user_id])
  end

  def o_auth_user_logged_in?
    !!current_o_auth_user
  end

  def o_auth_return_to
    request.base_url
  end

  def require_o_auth
    o_auth_login unless o_auth_user_logged_in?
  end

  def o_auth_login
    o_auth_session[:return_to] = o_auth_return_to
    redirect_to o_auth_facebook_path
  end

  def o_auth_logout
    session[:o_auth] = nil
    redirect_to o_auth_return_to || request.base_url
  end
end
