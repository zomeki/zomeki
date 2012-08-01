# encoding: utf-8
class PortalGroup::Public::Node::SiteCategoriesController < Cms::Controller::Public::Base
  include PortalGroup::Controller::SiteFeed

  def pre_dispatch
    return http_error(404) unless @content = Page.current_node.content
    
    @limit = 50
    
    if params[:name]
      item = PortalGroup::Category.new.public
      item.and :content_id, @content.id
      item.and :name, params[:name]
      return http_error(404) unless @item = item.find(:first)
      Page.current_item = @item
      Page.title        = @item.title
    end
  end
  
  def index
    @items = PortalGroup::Category.root_items(:content_id => @content.id, :state => 'public')
  end

  def show
    @page  = params[:page]
    
    return show_feed if params[:file] == "feed"
    return http_error(404) unless params[:file] =~ /^(index|more)$/
    @more  = (params[:file] == 'more')
    @page  = 1  if !@more && !request.mobile?
    @limit = 10 if !@more
    
    site = Cms::Site.new.public
    site.and :id, '!=', Page.site.id
    site.and :portal_group_id, @content.id
    site.and :portal_group_state, "visible"
    site.portal_category_is @item
    site.page @page, @limit
    @sites = site.find(:all, :order => 'created_at DESC')
    return true if render_feed(@sites)
    return http_error(404) if @more == true && @sites.current_page > @sites.total_pages
    
    if @item.level_no == 1
      show_group
      return render :action => :show_group
    elsif @item.level_no > 1
      show_detail
      return render :action => :show_detail
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

    @item_sites = Proc.new do |cate|
      site = Cms::Site.new.public
      site.and :id, '!=', Page.site.id
      site.and :portal_group_id, @content.id
      site.and :portal_group_state, "visible"
      site.portal_category_is cate
      site.page @page, @limit
      @sites = site.find(:all, :order => 'created_at DESC')
    end
  end

  def show_detail
    @items = PortalGroup::Business.root_items(:content_id => @content.id, :state => 'public')

    @item_sites = Proc.new do |attr|
      site = Cms::Site.new.public
      site.and :id, '!=', Page.site.id
      site.and :portal_group_id, @content.id
      site.and :portal_group_state, "visible"
      site.portal_category_is @item
      site.portal_business_is attr
      site.page @page, @limit
      @sites = site.find(:all, :order => 'created_at DESC')
    end
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
    site.portal_area_is @item
    site.portal_business_is @attr
    site.page @page, @limit
    @sites = site.find(:all, :order => 'created_at DESC')
    return http_error(404) if @sites.current_page > @sites.total_pages
  end
end
