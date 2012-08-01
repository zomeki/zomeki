# encoding: utf-8
class PortalGroup::Content::Group < Cms::Content
  def category_node
    return @category_node if @category_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::Category'
    @category_node = item.find(:first, :order => :id)
  end
  
  def business_node
    return @business_node if @business_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::Business'
    @business_node = item.find(:first, :order => :id)
  end
  
  def attribute_node
    return @attribute_node if @attribute_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::Attribute'
    @attribute_node = item.find(:first, :order => :id)
  end
  
  def area_node
    return @area_node if @area_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::Area'
    @area_node = item.find(:first, :order => :id)
  end
  
  def tag_node
    return @tag_node if @tag_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::TagDoc'
    @tag_node = item.find(:first, :order => :id)
  end
  
  def recent_node
    return @recent_node if @recent_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::RecentDoc'
    @recent_node = item.find(:first, :order => :id)
  end
  
  def site_node
    return @site_node if @site_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::Site'
    @site_node = item.find(:first, :order => :id)
  end
  
  def site_category_node
    return @site_category_node if @site_category_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::SiteCategory'
    @site_category_node = item.find(:first, :order => :id)
  end
  
  def site_business_node
    return @site_business_node if @site_business_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::SiteBusiness'
    @site_business_node = item.find(:first, :order => :id)
  end
  
  def site_attribute_node
    return @site_attribute_node if @site_attribute_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::SiteAttribute'
    @site_attribute_node = item.find(:first, :order => :id)
  end
  
  def site_area_node
    return @site_area_node if @site_area_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::SiteArea'
    @site_area_node = item.find(:first, :order => :id)
  end

  def thread_node
    return @thread_node if @thread_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::Thread'
    @thread_node = item.find(:first, :order => :id)
  end

  def thread_category_node
    return @thread_category_node if @thread_category_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::ThreadCategory'
    @thread_category_node = item.find(:first, :order => :id)
  end

  def thread_business_node
    return @thread_business_node if @thread_business_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::ThreadBusiness'
    @thread_business_node = item.find(:first, :order => :id)
  end

  def thread_attribute_node
    return @thread_attribute_node if @thread_attribute_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::ThreadAttribute'
    @thread_attribute_node = item.find(:first, :order => :id)
  end

  def thread_tag_node
    return @thread_tag_node if @thread_tag_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalGroup::TagThread'
    @thread_tag_node = item.find(:first, :order => :id)
  end
end
