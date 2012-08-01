# encoding: utf-8
class Laby::Admin::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    #default_url_options[:content] = @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    item = Laby::Doc.new#.public#.readable
    #item.public unless Core.user.has_auth?(:manager)
    item.and :content_id, @content.id
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'updated_at DESC'
    @items = item.find(:all)
    
    if @node = Laby::Content::Doc.find(@content.id).doc_node
      @preview_uri = "#{Core.full_uri}_preview/#{format('%08d', Page.site.id)}#{@node.public_uri}" 
    end
    
    _index @items
  end

  def show
    @item = Laby::Doc.new.find(params[:id])
    #return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Laby::Doc.new({
      :content_id   => @content.id,
      :state        => 'public',
    })
  end
  
  def create
    @item = Laby::Doc.new(params[:item])
    @item.content_id = @content.id
    
    if params[:commit_public]
      @item.state = "public"
      @item.published_at ||= Core.now
    else
      @item.state = "closed"
      @item.published_at = nil
    end
    
    _create @item
  end

  def update
    @item = Laby::Doc.new.find(params[:id])
    @item.attributes = params[:item]
    
    if params[:commit_public]
      @item.state = "public"
      @item.published_at ||= Core.now
    else
      @item.state = "closed"
      @item.published_at = nil
    end
    
    _update(@item)
  end
  
  def destroy
    @item = Laby::Doc.new.find(params[:id])
    _destroy @item
  end
end
