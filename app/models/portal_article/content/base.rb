# encoding: utf-8
class PortalArticle::Content::Base < Cms::Content
  has_many :dependent_docs, :foreign_key => :content_id, :class_name => 'PortalArticle::Doc',
    :dependent => :destroy
  has_many :dependent_categories, :foreign_key => :content_id, :class_name => 'PortalArticle::Category',
    :dependent => :destroy
end