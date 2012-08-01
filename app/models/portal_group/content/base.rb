# encoding: utf-8
class PortalGroup::Content::Base < Cms::Content
  has_many :dependent_categories, :foreign_key => :content_id, :class_name => 'PortalGroup::Category',
    :dependent => :destroy
  has_many :dependent_business, :foreign_key => :content_id, :class_name => 'PortalGroup::Business',
    :dependent => :destroy
  has_many :dependent_attributes, :foreign_key => :content_id, :class_name => 'PortalGroup::Attribute',
    :dependent => :destroy
  has_many :dependent_areas, :foreign_key => :content_id, :class_name => 'PortalGroup::Area',
    :dependent => :destroy
end