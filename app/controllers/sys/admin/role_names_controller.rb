# encoding: utf-8
class Sys::Admin::RoleNamesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end
  
  def index
    item = Sys::RoleName.new#.readable
    item.and :site_id, Core.site.id
    item.search(params)
    item.page  params[:page], params[:limit]
    item.order params[:sort], :name
    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = Sys::RoleName.new.find(params[:id])
    #return error_auth unless @item.readable?
    return error_auth unless @item.site_id == Core.site.id
    _show @item
  end

  def new
    @item = Sys::RoleName.new({
    })
  end
  
  def create
    @item = Sys::RoleName.new(params[:item])
    @item.site_id = Core.site.id
    _create @item
  end
  
  def update
    @item = Sys::RoleName.new.find(params[:id])
    return error_auth unless @item.site_id == Core.site.id
    @item.attributes = params[:item]
    _update @item
  end
  
  def destroy
    @item = Sys::RoleName.new.find(params[:id])
    return error_auth unless @item.site_id == Core.site.id
    _destroy @item
  end
end
