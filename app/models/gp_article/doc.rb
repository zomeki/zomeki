# encoding: utf-8
class GpArticle::Doc < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Concept

  TARGET_OPTIONS = [['同一ウィンドウ', '_self'], ['別ウィンドウ', '_blank']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'
  validates_presence_of :content_id

  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'

  has_and_belongs_to_many :categories, :class_name => 'GpCategory::Category', :join_table => 'gp_article_docs_gp_category_categories'

  def public_uri
    return @public_uri if @public_uri
    return nil unless node = content.doc_node
    @public_uri = "#{node.public_uri}#{id}"
  end

  def public_full_uri
    return @public_full_uri if @public_full_uri
    return nil unless node = content.doc_node
    @public_full_uri = "#{node.public_full_uri}#{id}"
  end
end
