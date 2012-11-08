# encoding: utf-8
class GpArticle::Admin::CategoryTypesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = GpArticle::Content::Doc.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = GpArticle::CategoryType.where(content_id: @content.id).paginate(page: params[:page], per_page: 20)
    _index @items
  end

  def show
    @item = GpArticle::CategoryType.find(params[:id])
    _show @item
  end

  def new
    @item = GpArticle::CategoryType.new(state: 'public', sort_no: 1)
  end

  def create
    @item = GpArticle::CategoryType.new(params[:item])
    @item.concept = @content.concept
    @item.content = @content
    @item.in_creator = {'group_id' => Core.user_group.id, 'user_id' => Core.user.id}
    _create @item
  end

  def edit
    @item = GpArticle::CategoryType.find(params[:id])
  end

  def update
    @item = GpArticle::CategoryType.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = GpArticle::CategoryType.find(params[:id])
    _destroy @item
  end

  def category_tree
    selected_ids = GpArticle::Doc.find_by_id(params[:doc_id]).try(:category_ids) || []
    tree = GpArticle::CategoryType.find(params[:category_type_id]).root_categories.map {|c| c.descendants(selected_ids) }
    render :js => tree.to_json, :layout => false
  end
end
