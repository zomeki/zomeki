# encoding: utf-8
class Sys::Admin::UsersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end
  
  def index
    @item = Sys::User.new # for search
    @item.in_group_id = params[:s_group_id]
    
    item = Sys::User.new
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], "LPAD(account, 15, '0')"

    # システム管理者以外は選択サイトのユーザしか操作できない
    unless Core.user.root?
      item.join ['JOIN sys_users_groups AS sug ON sug.user_id = sys_users.id',
                 'JOIN cms_site_belongings AS csb ON csb.group_id = sug.group_id'].join(' ')
      item.and 'csb.site_id', Core.site.id
    end

    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = Sys::User.new.find(params[:id])
    return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Sys::User.new({
      :state       => 'enabled',
      :ldap        => '0',
      :auth_no     => 2
    })
  end
  
  def create
    @item = Sys::User.new(params[:item])

    _create(@item) do
      unless Core.user.root?
        @item.sites.clear
        @item.sites << Core.site
      end
    end
  end
  
  def update
    @item = Sys::User.new.find(params[:id])
    @item.attributes = params[:item]
    _update(@item)
  end
  
  def destroy
    @item = Sys::User.new.find(params[:id])
    _destroy(@item)
  end
end
