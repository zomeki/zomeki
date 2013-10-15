# encoding: utf-8
class Survey::Admin::FormsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Survey::Content::Form.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @content.forms.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    @item = @content.forms.find(params[:id])
    _show @item
  end

  def new
    @item = @content.forms.build
  end

  def create
    @item = @content.forms.build(params[:item])
    _create @item
  end

  def update
    @item = @content.forms.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = @content.forms.find(params[:id])
    _destroy @item
  end
end
