# encoding: utf-8
class AdBanner::Content::Banner < Cms::Content
  default_scope where(model: 'AdBanner::Banner')

  has_many :banners, :foreign_key => :content_id, :class_name => 'AdBanner::Banner', :order => :sort_no, :dependent => :destroy
  has_many :groups, :foreign_key => :content_id, :class_name => 'AdBanner::Group', :order => :sort_no, :dependent => :destroy
end
