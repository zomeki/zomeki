# encoding: utf-8
class PortalArticle::Content::Doc < Cms::Content
  def portal_group
    group_id = setting_value(:portal_group_id)
    return nil if group_id.blank?
    PortalGroup::Content::Group.find_by_id(group_id)
  end
  
  def doc_node
    return @doc_node if @doc_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalArticle::Doc'
    @doc_node = item.find(:first, :order => :id)
  end
  
  def category_node
    return @category_node if @category_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalArticle::Category'
    @category_node = item.find(:first, :order => :id)
  end
  
  def tag_node
    return @tag_node if @tag_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalArticle::TagDoc'
    @tag_node = item.find(:first, :order => :id)
  end
  
  def recent_node
    return @recent_node if @recent_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalArticle::RecentDoc'
    @recent_node = item.find(:first, :order => :id)
  end

  def archive_node
    return @archive_node if @archive_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PortalArticle::Archive'
    @archive_node = item.find(:first, :order => :id)
  end
  
  def portal_category_node
    return @portal_category_node if @portal_category_node
    portal_group_id = setting_value(:portal_group_id)
    return nil unless portal_group_id
    item = Cms::Node.new.public
    item.and :content_id, portal_group_id
    item.and :model, 'PortalGroup::Category'
    @portal_category_node = item.find(:first, :order => :id)
  end
  
  def portal_business_node
    return @portal_business_node if @portal_business_node
    portal_group_id = setting_value(:portal_group_id)
    return nil unless portal_group_id
    item = Cms::Node.new.public
    item.and :content_id, portal_group_id
    item.and :model, 'PortalGroup::Business'
    @portal_business_node = item.find(:first, :order => :id)
  end
  
  def portal_attribute_node
    return @portal_attribute_node if @portal_attribute_node
    portal_group_id = setting_value(:portal_group_id)
    return nil unless portal_group_id
    item = Cms::Node.new.public
    item.and :content_id, portal_group_id
    item.and :model, 'PortalGroup::Attribute'
    @portal_attribute_node = item.find(:first, :order => :id)
  end
  
  def portal_area_node
    return @portal_area_node if @portal_area_node
    portal_group_id = setting_value(:portal_group_id)
    return nil unless portal_group_id
    item = Cms::Node.new.public
    item.and :content_id, portal_group_id
    item.and :model, 'PortalGroup::Area'
    @portal_area_node = item.find(:first, :order => :id)
  end
end