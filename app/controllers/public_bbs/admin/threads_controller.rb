# encoding: utf-8
class PublicBbs::Admin::ThreadsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    return error_auth unless @content = PublicBbs::Content::Thread.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    unless (@portal_group = @content.portal_group)
      flash[:notice] = 'ポータル記事分類を設定してください。'
      redirect_to(public_bbs_content_settings_path)
    end
  end

  def index
    item = PublicBbs::Thread.new
    item.and :content_id, @content.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'updated_at DESC'
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = PublicBbs::Thread.new.find(params[:id])
    _show @item
  end

  def new
    @item = PublicBbs::Thread.new(:content => @content)
    @item.state = 'closed'
  end

  def create
    @item = PublicBbs::Thread.new(params[:item])
    @item.content      = @content
    @item.portal_group = @content.portal_group
    _create(@item) do
      @item.fix_tmp_files(params[:_tmp])
    end
  end

  def update
    @item = PublicBbs::Thread.new.find(params[:id])
    @item.update_attributes(params[:item])
    _update @item
  end

  def destroy
    @item = PublicBbs::Thread.new.find(params[:id])
    _destroy @item
  end
end
