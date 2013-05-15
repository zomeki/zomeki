# encoding: utf-8
class Portal::Admin::FeedEntriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless @feed = Cms::Feed.find(params[:feed])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    #default_url_options[:content] = @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    item = Portal::FeedEntry.new
    item.and :feed_id, @feed.id
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'entry_updated ASC, id DESC'
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Portal::FeedEntry.new.find(params[:id])
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

protected
end
