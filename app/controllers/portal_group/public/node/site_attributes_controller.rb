# encoding: utf-8
class PortalGroup::Public::Node::SiteAttributesController < Cms::Controller::Public::Base
  include PortalGroup::Controller::SiteFeed

  def pre_dispatch
    return http_error(404) unless @content = Page.current_node.content
    
    @limit = 50
    
    if params[:name]
      item = PortalGroup::Attribute.new.public
      item.and :content_id, @content.id
      item.and :name, params[:name]
      return http_error(404) unless @item = item.find(:first)
      Page.current_item = @item
      Page.title        = @item.title
    end
  end
  
  def index
    item = PortalGroup::Attribute.new.public
    item.and :content_id, @content.id
    @items = item.find(:all, :order => :sort_no)
  end
  
  def show
    @page  = params[:page]
    
    return show_feed if params[:file] == "feed"
    return http_error(404) unless params[:file] =~ /^(index|more)$/
    @more  = params[:file] == 'more'
    @page  = 1  if !@more && !request.mobile?
    @limit = 10 if !@more
    
    site = Cms::Site.new.public
    site.and :id, '!=', Page.site.id
    site.and :portal_group_id, @content.id
    site.and :portal_group_state, "visible"
    site.portal_attribute_is @item
    site.page @page, @limit
    @sites = site.find(:all, :order => 'created_at DESC')
    return true if render_feed(@sites)
    return http_error(404) if @more == true && @sites.current_page > @sites.total_pages
    
    @items = PortalGroup::Business.root_items(:content_id => @content.id, :state => 'public')

    @item_sites = Proc.new do |cate|
      site = Cms::Site.new.public
      site.and :id, '!=', Page.site.id
      site.and :portal_group_id, @content.id
      site.and :portal_group_state, "visible"
      site.portal_attribute_is @item
      site.portal_business_is cate
      site.page @page, @limit
      @sites = site.find(:all, :order => 'created_at DESC')
    end
  end
  
  def show_feed #portal
    @feed = true
    @items = []
    return render(:action => :show)
  end
  
  def show_attr
    @page  = params[:page]
    
    attr = PortalGroup::Business.new.public
    attr.and :content_id, @content.id
    attr.and :name, params[:attr]
    return http_error(404) unless @attr = attr.find(:first, :order => :sort_no)
    
    site = Cms::Site.new.public
    site.and :id, '!=', Page.site.id
    site.and :portal_group_id, @content.id
    site.and :portal_group_state, "visible"
    site.portal_attribute_is @item
    site.portal_business_is @attr
    site.page @page, @limit
    @sites = site.find(:all, :order => 'created_at DESC')
    return http_error(404) if @sites.current_page > @sites.total_pages
  end
end
