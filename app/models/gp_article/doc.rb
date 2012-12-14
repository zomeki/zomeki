class GpArticle::Doc < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Concept

  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'

  validates :concept_id, :presence => true
  validates :content_id, :presence => true

  has_and_belongs_to_many :categories, :class_name => 'GpArticle::Category', :join_table => 'gp_article_categories_gp_article_docs'

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
