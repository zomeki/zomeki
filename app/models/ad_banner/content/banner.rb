# encoding: utf-8
class AdBanner::Content::Banner < Cms::Content
  default_scope where(model: 'AdBanner::Banner')

  has_many :banners, :foreign_key => :content_id, :class_name => 'AdBanner::Banner', :dependent => :destroy
  has_many :groups, :foreign_key => :content_id, :class_name => 'AdBanner::Group', :dependent => :destroy
end
