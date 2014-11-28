# encoding: utf-8
class Sys::Admin::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.root?
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = Sys::Setting.configs
    _index @items
  end

  def show
    @item = Sys::Setting.config(params[:id])
    _show @item
  end

  def new
    error_auth
  end

  def create
    error_auth
  end

  def update
    @item = Sys::Setting.config(params[:id])
    @item.value = params[:item][:value]

    if @item.name.in?('common_ssl','file_upload_max_size')
      extra_values = @item.extra_values

      case @item.name
      when 'common_ssl'
        extra_values[:common_ssl_uri] = params[:common_ssl_uri]
      when 'file_upload_max_size'
        extra_values[:extension_upload_max_size] = params[:extension_upload_max_size]
      end

      @item.extra_values = extra_values
    end
    _update(@item) do
      update_config if @item.name.in?('ssl')
    end
  end

  def destroy
    error_auth
  end

  def update_config
    Cms::Site.put_virtual_hosts_config
  end

end
