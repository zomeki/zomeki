# encoding: utf-8
class Cms::Admin::Site::BasicAuthUsersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  after_filter :refresh_auth, only: [:create, :update, :destroy]

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    @site = Cms::Site.find(params[:site])
  end

  def index
    @items = @site.basic_auth_users.paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = @site.basic_auth_users.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = @site.basic_auth_users.build(state: 'enabled')
  end

  def create
    @item = @site.basic_auth_users.build(params[:item])
    _create(@item) do
    end
  end

  def update
    @item = @site.basic_auth_users.find(params[:id])
    @item.attributes = params[:item]
    _update(@item) do
    end
  end

  def destroy
    @item = @site.basic_auth_users.find(params[:id])
    _destroy(@item) do
    end
  end

  def enable_auth
    @site.enable_basic_auth

    flash[:notice] = 'Basic認証を有効にしました。'
    redirect_to cms_site_basic_auth_users_path(@site)
  end

  def disable_auth
    @site.disable_basic_auth

    flash[:notice] = 'Basic認証を無効にしました。'
    redirect_to cms_site_basic_auth_users_path(@site)
  end

  private

  def refresh_auth
    if @site.basic_auth_users.where(state: 'enabled').empty?
      @site.disable_basic_auth
      flash[:notice] = 'Basic認証を無効にしました。'
    else
      if @site.basic_auth_enabled?
        @site.enable_basic_auth
      else
        @site.disable_basic_auth
      end
    end
  end
end
