# encoding: utf-8
class Sys::Admin::GroupsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

# TODO: サイトの絞り込み処理が分散してしまっているのでまとめる
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)

    id      = params[:parent] == '0' ? 1 : params[:parent]
    @parent = Sys::Group.new.find(id)

    # システム管理者以外は選択サイトのグループしか操作できない
    unless Core.user.root?
      return error_auth unless @parent.id == 1 || @parent.site_ids.include?(Core.site.id)
    end

    item = Sys::Group.new.readable
    item.order params[:sort], 'sort_no, code, id'

    # システム管理者以外は選択サイトのグループしか操作できない
    unless Core.user.root?
      site_restriction = {
             joins: ['JOIN cms_site_belongings AS csb ON csb.group_id = sys_groups.id'],
        conditions: ['csb.site_id = ? AND sys_groups.parent_id = ?', Core.site.id, @parent.id]
      }
    else
      item.and :parent_id, @parent.id
    end

    @groups = item.find(:all, site_restriction)

    item = Sys::User.new.readable
    item.order params[:sort], "LPAD(account, 15, '0')"

    # システム管理者以外は選択サイトのユーザしか操作できない
    unless Core.user.root?
      site_restriction = {
             joins: ['JOIN sys_users_groups AS sug ON sug.user_id = sys_users.id',
                     'JOIN cms_site_belongings AS csb ON csb.group_id = sug.group_id'],
        conditions: ['csb.site_id = ? AND sug.group_id = ?', Core.site.id, @parent.id]
      }
    else
      item.join :groups
      item.and 'sys_groups.id', @parent
    end

    @users = item.find(:all, site_restriction)
  end
  
  def index
    item = Sys::Group.new.readable
    item.and :parent_id, @parent.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], :id

    # システム管理者以外は選択サイトのグループしか操作できない
    unless Core.user.root?
      site_restriction = {
             joins: ['JOIN cms_site_belongings AS csb ON csb.group_id = sys_groups.id'],
        conditions: ['csb.site_id = ?', Core.site.id]
      }
    end

    @items = item.find(:all, site_restriction)
    _index @items
  end
  
  def show
    @item = Sys::Group.new.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Sys::Group.new({
      :state      => 'enabled',
      :parent_id  => @parent.id,
      :ldap       => 0,
      :web_state  => 'public'
    })
  end
  
  def create
    @item = Sys::Group.new(params[:item])
    @item.parent_id = @parent.id
    parent = Sys::Group.find_by_id(@item.parent_id)
    @item.level_no = parent ? parent.level_no + 1 : 1
    _create(@item) do
      @item.sites << Core.site unless Core.user.root?
    end
  end
  
  def update
    @item = Sys::Group.new.find(params[:id])
    @item.attributes = params[:item]
    parent = Sys::Group.find_by_id(@item.parent_id)
    @item.level_no = parent ? parent.level_no + 1 : 1
    _update @item
  end
  
  def destroy
    @item = Sys::Group.new.find(params[:id])
    _destroy @item
  end
end
