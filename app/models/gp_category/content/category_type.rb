# encoding: utf-8
class GpCategory::Content::CategoryType < Cms::Content
  default_scope where(model: 'GpCategory::CategoryType')

  has_many :category_types, :foreign_key => :content_id, :class_name => 'GpCategory::CategoryType', :order => :sort_no, :dependent => :destroy
end
