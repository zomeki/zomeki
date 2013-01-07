# encoding: utf-8
class GpArticle::Doc < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::File
  include Sys::Model::Rel::Task
  include Cms::Model::Auth::Concept
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Rel::Inquiry
  include Cms::Model::Rel::Map

  TARGET_OPTIONS = [['同一ウィンドウ', '_self'], ['別ウィンドウ', '_blank']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'
  validates_presence_of :content_id

  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'

  has_and_belongs_to_many :categories, :class_name => 'GpCategory::Category', :join_table => 'gp_article_docs_gp_category_categories'

  before_save :set_name

  validates :title, :presence => true, :length => {maximum: 200}
  validates :body, :length => {maximum: 100000}

  def public_uri=(uri)
    @public_uri = uri
  end

  def public_uri
    return @public_uri if @public_uri
    return nil unless node = content.doc_node
    @public_uri = "#{node.public_uri}#{name}/"
  end

  def public_full_uri=(uri)
    @public_full_uri = uri
  end

  def public_full_uri
    return @public_full_uri if @public_full_uri
    return nil unless node = content.doc_node
    @public_full_uri = "#{node.public_full_uri}#{name}/"
  end

  private

  def set_name
    return unless self.name.blank?
    date = created_at.try(:strftime, '%Y%m%d')
    date ||= Date.strptime(Core.now, '%Y-%m-%d').strftime('%Y%m%d')
    seq = Util::Sequencer.next_id('gp_article_docs', :version => date)
    self.name = Util::String::CheckDigit.check(date + format('%04d', seq))
  end
end
