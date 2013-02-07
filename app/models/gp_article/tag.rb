class GpArticle::Tag < ActiveRecord::Base
  include Sys::Model::Base

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'
  validates_presence_of :content_id

  def public_uri=(uri)
    @public_uri = uri
  end

  def public_uri
    return @public_uri if @public_uri
    return '' unless node = content.tag_node
    @public_uri = "#{node.public_uri}#{CGI::escape(word)}/"
  end
end
