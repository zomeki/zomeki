# encoding: utf-8
class Sys::Admin::TransferredFilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    @site = Core.site
    @destination_uri = @site.setting_transfer_dest_domain
  end

  def index
    item = Sys::TransferredFile.new
    item.and :site_id, @site.id
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'version DESC, id'
    @items = item.find(:all)

    _index @items
  end

  def show
    @item = Sys::TransferredFile.new.find(params[:id])
    _show @item
  end

  def new
    return error_auth
  end

  def create
    return error_auth
  end

  def update
    return error_auth
  end

  def destroy
    return error_auth
  end
end
