# encoding: utf-8
class Sys::Admin::GroupUsersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    
    id      = params[:parent] == '0' ? 1 : params[:parent]
    @parent = Sys::Group.new.find(id)
    #default_url_options[:parent] = @parent
  end
  
  def index
    if params[:options]
      render 'index_options', :layout => false
    else
      redirect_to(sys_groups_path(@parent))
    end
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
      :auth_no     => 2,
      :in_group_id => @parent.id
    })
  end
  
  def create
    @item = Sys::User.new(params[:item])
    _create(@item, :location => sys_groups_path(@parent))
  end
  
  def update
    @item = Sys::User.new.find(params[:id])
    @item.attributes = params[:item]
    _update(@item, :location => sys_groups_path(@parent))
  end
  
  def destroy
    @item = Sys::User.new.find(params[:id])
    _destroy(@item, :location => sys_groups_path(@parent))
  end
end
