# encoding: utf-8
class PublicBbs::Admin::ResponsesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication

  before_filter :get_thread # 必ず最初

  def pre_dispatch
    return error_auth unless @content = PublicBbs::Content::Thread.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    item = PublicBbs::Response.new
    item.and :thread_id, @thread.id
    item.and :content_id, @content.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'updated_at DESC'
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = PublicBbs::Response.new.find(params[:id])
    _show @item
  end

  def new
    @item = PublicBbs::Response.new(:content => @content)
    @item.state = 'closed'
  end

  def create
    @item = @thread.responses.build(params[:item])
    @item.content = @content
    _create(@item) do
      @item.fix_tmp_files(params[:_tmp])
    end
  end

  def update
    @item = PublicBbs::Response.new.find(params[:id])
    @item.update_attributes(params[:item])
    _update @item
  end

  def destroy
    @item = PublicBbs::Response.new.find(params[:id])
    _destroy @item
  end

  def get_thread
    thread = PublicBbs::Thread.new
    thread.and :content_id, @content.id
    thread.and :id, params[:thread_id]
    return http_error(404) unless @thread = thread.find(:first)
  end
end
