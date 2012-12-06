# encoding: utf-8
class GpArticle::Content::Doc < Cms::Content
  has_many :category_types, :foreign_key => :content_id, :class_name => 'GpArticle::CategoryType', :order => :sort_no, :dependent => :destroy
end
