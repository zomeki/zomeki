class Tag::Tag < ActiveRecord::Base
  include Sys::Model::Base

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Tag::Content::Tag'
  validates_presence_of :content_id

  # Proper
  has_and_belongs_to_many :docs, :class_name => 'GpArticle::Doc', :join_table => 'gp_article_docs_tag_tags', :order => 'published_at DESC',
    :after_add => :update_last_tagged_at, :after_remove => :update_last_tagged_at

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

  def public_docs
    docs.mobile(::Page.mobile?).public
  end

  def update_last_tagged_at(doc=nil)
    update_column(:last_tagged_at, Time.now)
  end
end
