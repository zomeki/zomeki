# encoding: utf-8
class Sys::Admin::MaintenancesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    @maintenances = Core.site.maintenances
  end

  def index
    @items = @maintenances.order('published_at DESC')
                          .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = @maintenances.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = @maintenances.build(state: 'public', published_at: Core.now)
  end

  def create
    @item = @maintenances.build(params[:item])
    _create @item
  end
  
  def update
    @item = @maintenances.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = @maintenances.find(params[:id])
    _destroy @item
  end
end
