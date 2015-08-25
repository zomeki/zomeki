# encoding: utf-8
class Cms::Admin::Tool::ConvertLinksController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    @item = Tool::ConvertLink.find(params[:id]) if params[:id].present?
    @items = Tool::ConvertLink.order('created_at desc').paginate(page: params[:page], per_page: 10)
  end

  def index
    if params[:linkable_type] || params[:concept_id]
      options = Tool::ConvertLink.new(linkable_type: params[:linkable_type], concept_id: params[:concept_id]).linkable_id_options
      return render text: ApplicationController.helpers.options_for_select(options)
    end
    @item = Tool::ConvertLink.new(params[:item])
    _index @items
  end

  def show
    _show @item
  end

  def create
    @item = Tool::ConvertLink.new(params[:item])
    if @item.creatable? && @item.valid?
      _create @item
    else
      render :index
    end
  end

  def destroy
    _destroy @item
  end
end

