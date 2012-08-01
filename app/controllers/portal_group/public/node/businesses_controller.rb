# encoding: utf-8
class PortalGroup::Public::Node::BusinessesController < Cms::Controller::Public::Base
  include PortalGroup::Controller::Feed
  
  def pre_dispatch
    return http_error(404) unless @content = Page.current_node.content
    
    @limit = 50
    
    if params[:name]
      item = PortalGroup::Business.new.public
      item.and :content_id, @content.id
      item.and :name, params[:name]
      return http_error(404) unless @item = item.find(:first)
      Page.current_item = @item
      Page.title        = @item.title
    end
  end
  
  def index
    @items = PortalGroup::Business.root_items(:content_id => @content.id, :state => 'public')
  end

  def show
    @page  = params[:page]
    
    return show_feed if params[:file] == "feed"
    return http_error(404) unless params[:file] =~ /^(index|more)$/
    @more  = params[:file] == 'more'
    @page  = 1  if !@more && !request.mobile?
    @limit = 10 if !@more
    
    doc = PortalArticle::Doc.new.public
    doc.agent_filter(request.mobile)
    doc.and :portal_group_id, @content.id
    doc.and :portal_group_state, "visible"
    doc.portal_business_is @item
    doc.page @page, @limit
    @docs = doc.find(:all, :order => 'published_at DESC')
    return true if render_feed(@docs)
    return http_error(404) if @more == true && @docs.current_page > @docs.total_pages

    if @item.level_no == 1
      show_group
      return render(:action => :show_group)
    elsif @item.level_no > 1
      show_detail
      return render(:action => :show_detail)
    end
    return http_error(404)
  end

  def show_feed #portal
    @feed = true
    @items = []
    return render(:action => :show_group)
  end
  
  def show_group
    @items = @item.public_children

    @item_docs = Proc.new do |city|
      doc = PortalArticle::Doc.new.public
      doc.agent_filter(request.mobile)
      doc.and :portal_group_id, @content.id
      doc.and :portal_group_state, "visible"
      doc.portal_business_is city
      doc.page @page, @limit
      @docs = doc.find(:all, :order => 'published_at DESC')
    end
  end

  def show_detail
    @items = PortalGroup::Attribute.new.public.find(:all, :conditions => {:content_id => @content.id}, :order => :sort_no)

    @item_docs = Proc.new do |attr|
      doc = PortalArticle::Doc.new.public
      doc.agent_filter(request.mobile)
      doc.and :portal_group_id, @content.id
      doc.and :portal_group_state, "visible"
      doc.portal_business_is @item
      doc.portal_attribute_is attr
      doc.page @page, @limit
      @docs = doc.find(:all, :order => 'published_at DESC')
    end
  end
  
  def show_attr
    @page  = params[:page]
    
    attr = PortalGroup::Attribute.new.public
    attr.and :content_id, @content.id
    attr.and :name, params[:attr]
    return http_error(404) unless @attr = attr.find(:first, :order => :sort_no)
    
    doc = PortalArticle::Doc.new.public
    doc.agent_filter(request.mobile)
    doc.and :portal_group_id, @content.id
    doc.and :portal_group_state, "visible"
    doc.portal_business_is @item
    doc.portal_attribute_is @attr
    doc.page @page, @limit
    @docs = doc.find(:all, :order => 'published_at DESC')
    return http_error(404) if @docs.current_page > @docs.total_pages
  end
end
