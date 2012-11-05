# encoding: utf-8
class GpArticle::Admin::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = GpArticle::Content::Doc.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = GpArticle::Doc.where(content_id: @content.id).paginate(page: params[:page], per_page: 20).order('updated_at DESC')
    _index @items
  end

  def show
    @item = GpArticle::Doc.find(params[:id])
    _show @item
  end

  def new
    @item = GpArticle::Doc.new
  end

  def create
    @item = GpArticle::Doc.new(params[:item])
    @item.concept = @content.concept
    @item.content = @content
    @item.in_creator = {'group_id' => Core.user_group.id, 'user_id' => Core.user.id}
    _create @item
  end

  def edit
    @item = GpArticle::Doc.find(params[:id])
  end

  def update
    @item = GpArticle::Doc.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = GpArticle::Doc.find(params[:id])
    _destroy @item
  end
end
