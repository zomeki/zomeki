# encoding: utf-8
class PublicBbs::Admin::CategoriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = PublicBbs::Content::Thread.find(params[:content])

    if params[:parent] == '0'
      @parent = PublicBbs::Category.new(:level_no => 0)
      @parent.id = 0
    else
      @parent = PublicBbs::Category.new.find(params[:parent])
    end
  end

  def index
    item = PublicBbs::Category.new
    item.and :parent_id, @parent
    item.and :content_id, @content
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = PublicBbs::Category.new.find(params[:id])
    _show @item
  end

  def new
    @item = PublicBbs::Category.new(:state => 'public', :sort_no => 1)
  end

  def create
    @item = PublicBbs::Category.new(params[:item])
    @item.content  = @content
    @item.parent   = @parent
    @item.level_no = @parent.level_no + 1
    _create @item
  end

  def update
    @item = PublicBbs::Category.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = PublicBbs::Category.new.find(params[:id])
    _destroy @item
  end
end
