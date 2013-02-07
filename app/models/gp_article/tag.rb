class GpArticle::Tag < ActiveRecord::Base
  include Sys::Model::Base

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'
  validates_presence_of :content_id

  # Proper
  has_and_belongs_to_many :docs, :class_name => 'GpArticle::Doc', :join_table => 'gp_article_docs_gp_article_tags'

  def public_uri=(uri)
    @public_uri = uri
  end

  def public_uri
    return @public_uri if @public_uri
    return '' unless node = content.tag_node
    @public_uri = "#{node.public_uri}#{CGI::escape(word)}/"
  end

  def bread_crumbs(tag_node)
    crumbs = []

    crumb = tag_node.bread_crumbs.crumbs.first
    crumb << [word, "#{tag_node.public_uri}#{CGI::escape(word)}/"]
    crumbs << crumb

    if crumbs.empty?
      tag_node.routes.each do |r|
        crumb = []
        r.each {|r| crumb << [r.title, r.public_uri] }
        crumbs << crumb
      end
    end

    Cms::Lib::BreadCrumbs.new(crumbs)
  end
end
