# encoding: utf-8
class Rank::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Rank::Controller::Rank

#  after_filter :flash_clear

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Rank::Content::Rank.find(params[:content])
    return error_auth unless @content.editable?
  end

  def index
    @items = Rank::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = Rank::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def edit
    @item = Rank::Content::Setting.config(@content, params[:id])
  end

  def update
    @item = Rank::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]

    if @item.name.in?('google_oauth')
      extra_values = @item.extra_values

      case @item.name
      when 'google_oauth'
        extra_values[:client_id] = params[:client_id].to_s
        extra_values[:client_secret] = params[:client_secret].to_s
        extra_values[:auth_code] = params[:auth_code].to_s

        if extra_values[:client_id].present? && extra_values[:client_secret].present?
          credentials = GoogleOauth2Installed.credentials
          credentials[:oauth2_client_id] = extra_values[:client_id]
          credentials[:oauth2_client_secret] = extra_values[:client_secret]
          credentials[:oauth2_scope] = 'https://www.googleapis.com/auth/analytics.readonly'

          setup = GoogleOauth2Installed::Setup.new(credentials)
          extra_values[:auth_url] = setup.zomeki_get_auth_url if extra_values[:auth_url].blank?
          if extra_values[:auth_code].present?
            token = setup.zomeki_get_access_token(extra_values[:auth_code])
            extra_values[:oauth2_token] = {access_token: token.token.to_s,
                                           refresh_token: token.refresh_token.to_s,
                                           expires_at: token.expires_at.to_i}
            extra_values[:auth_code] = nil
          end
        else
          extra_values[:auth_url] = nil
          extra_values[:auth_code] = nil
          extra_values[:oauth2_token] = nil
        end

        @item.value = if extra_values[:oauth2_token].kind_of?(Hash)
                        '設定済'
                      else
                        nil
                      end
        location = url_for(action: 'edit') if @item.value.blank?
      end

      @item.extra_values = extra_values
    end

    _update @item, location: location
  end

  def import
    get_access(@content, nil)
    redirect_to :action => :index
  end

  def makeup
    calc_access(@content)
    redirect_to :action => :index
  end

  def flash_clear
    flash[:alert ] = nil
    flash[:notice] = nil
  end
end
