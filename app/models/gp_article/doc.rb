# encoding: utf-8
class GpArticle::Doc < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::UnidRelation
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::File
  include Sys::Model::Rel::Recognition
  include Sys::Model::Rel::Task
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Rel::Inquiry
  include Cms::Model::Rel::Map

  include Cms::Model::Auth::Concept
  include Sys::Model::Auth::EditableGroup

  STATE_OPTIONS = [['下書き保存', 'draft'], ['承認待ち', 'recognize'], ['公開保存', 'public']]
  TARGET_OPTIONS = [['同一ウィンドウ', '_self'], ['別ウィンドウ', '_blank'], ['無効', '']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'
  validates_presence_of :content_id

  # Page
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  has_and_belongs_to_many :categories, :class_name => 'GpCategory::Category', :join_table => 'gp_article_docs_gp_category_categories'

  before_save :set_name

  validates :title, :presence => true, :length => {maximum: 200}
  validates :body, :length => {maximum: 100000}
  validates :state, :presence => true

  validate :validate_inquiry, :if => :state_recognize?
  validate :validate_recognizers, :if => :state_recognize?

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

  def state_options
    unless Core.user.has_auth?(:manager)
      STATE_OPTIONS.reject {|so| so.last == 'public' }
    else
      STATE_OPTIONS
    end
  end

  def state_draft?
    state == 'draft'
  end

  def state_recognize?
    state == 'recognize'
  end

  def state_public?
    state == 'public'
  end

  def change_state_by_commit(commit_state)
    new_state = commit_state.to_s.sub('commit_', '')
    self.state = new_state if STATE_OPTIONS.any? {|so| so.last == new_state }
  end

  def close
    @save_mode = :close
    self.state = 'closed' if self.state_public?
    return false unless save(:validate => false)
    close_page
    return true
  end

  def close_page(options={})
    return false unless super
    publishers.destroy_all unless publishers.empty?
    FileUtils.rm_f(::File.dirname(public_path))
    return true
  end

  def publish(content)
    @save_mode = :publish
    self.state = 'public'
    self.published_at ||= Core.now
    return false unless save(:validate => false)

    if (rep = replaced_page)
      rep.destroy
    end

    publish_page(content, :path => public_path, :uri => public_uri)
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
