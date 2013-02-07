# encoding: utf-8
class GpArticle::Doc < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::UnidRelation
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::EditableGroup
  include Sys::Model::Rel::File
  include Sys::Model::Rel::Recognition
  include Sys::Model::Rel::Task
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Rel::Inquiry
  include Cms::Model::Rel::Map

  include Cms::Model::Auth::Concept
  include Sys::Model::Auth::EditableGroup

  include GpArticle::Model::Rel::Doc::Rel

  STATE_OPTIONS = [['下書き保存', 'draft'], ['承認依頼', 'recognize'], ['即時公開', 'public']]
  TARGET_OPTIONS = [['無効', ''], ['同一ウィンドウ', '_self'], ['別ウィンドウ', '_blank'], ['添付ファイル', 'attached_file']]
  EVENT_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'
  validates_presence_of :content_id

  # Page
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  has_and_belongs_to_many :categories, :class_name => 'GpCategory::Category', :join_table => 'gp_article_docs_gp_category_categories'
  has_and_belongs_to_many :tags, :class_name => 'Tag::Tag', :join_table => 'gp_article_docs_tag_tags',
                          :conditions => proc { ['content_id = ?', self.content.tag_content_tag.try(:id)] }

  before_save :set_name

  validates :title, :presence => true, :length => {maximum: 200}
  validates :mobile_title, :length => {maximum: 200}
  validates :body, :length => {maximum: 100000}
  validates :mobile_body, :length => {maximum: 100000}
  validates :state, :presence => true

  validate :validate_inquiry
  validate :validate_recognizers, :if => :state_recognize?
  validate :validate_platform_dependent_characters

  validate :node_existence

  after_initialize :set_defaults
  after_save :set_tags

  scope :public, where(state: 'public')

  def self.find_with_content_and_criteria(content, criteria)
    docs = self.arel_table
    creators = Sys::Creator.arel_table
    groups = Sys::Group.arel_table

    arel = docs.project(docs.columns).join(creators, Arel::Nodes::InnerJoin).on(docs[:unid].eq(creators[:id]))
                                     .join(groups, Arel::Nodes::InnerJoin).on(creators[:group_id].eq(groups[:id]))
    arel.where(docs[:content_id].eq(content.id))

    arel.where(docs[:id].eq(criteria[:id])) if criteria[:id].present?
    arel.where(docs[:title].matches("%#{criteria[:title]}%")) if criteria[:title].present?
    arel.where(groups[:name].matches("%#{criteria[:group]}%")) if criteria[:group].present?

    arel.order(docs[:updated_at].desc)

    self.find_by_sql(arel.to_sql)
  end

  def state=(new_state)
    self.published_at ||= Core.now if new_state == 'public'
    super
  end

  def raw_tags=(raw_tags)
    super raw_tags.gsub('　', ' ')
  end

  def public_uri=(uri)
    @public_uri = uri
  end

  def public_uri
    return @public_uri if @public_uri
    return '' unless node = content.doc_node
    @public_uri = "#{node.public_uri}#{name}/"
  end

  def public_full_uri=(uri)
    @public_full_uri = uri
  end

  def public_full_uri
    return @public_full_uri if @public_full_uri
    return '' unless node = content.doc_node
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

  def search(search_params)
    search_params.each do |key, value|
      next if value.blank?

      case key
      when 's_id'
        self.and "#{GpArticle::Doc.table_name}.id", value
      when 's_title'
        self.and_keywords value, :title
      when 's_affiliation_name'
        self.join :creator
        self.join "INNER JOIN #{Sys::Group.table_name} ON #{Sys::Group.table_name}.id = #{Sys::Creator.table_name}.group_id"
        self.and "#{Sys::Group.table_name}.name", 'LIKE', "%#{value}%"
      end
    end

    return self
  end

  def bread_crumbs(doc_node)
    crumbs = []

    categories.each do |category|
      category_type = category.category_type
      if (node = category.content.category_type_node)
        crumb = node.bread_crumbs.crumbs.first
        crumb << [category_type.title, "#{node.public_uri}#{category_type.name}/"]
        category.ancestors.each {|a| crumb << [a.title, "#{node.public_uri}#{category_type.name}/#{a.path_from_root_category}/"] }
        crumbs << crumb
      end
    end

    if crumbs.empty?
      doc_node.routes.each do |r|
        crumb = []
        r.each {|i| crumb << [i.title, i.public_uri] }
        crumbs << crumb
      end
    end

    Cms::Lib::BreadCrumbs.new(crumbs)
  end

  private

  def set_name
    return unless self.name.blank?
    date = created_at.try(:strftime, '%Y%m%d')
    date ||= Date.strptime(Core.now, '%Y-%m-%d').strftime('%Y%m%d')
    seq = Util::Sequencer.next_id('gp_article_docs', :version => date)
    self.name = Util::String::CheckDigit.check(date + format('%04d', seq))
  end

  def set_defaults
    self.target ||= TARGET_OPTIONS.first.last
    self.event_state ||= 'hidden'
  rescue ActiveModel::MissingAttributeError => evar
    logger.warn(evar.message)
  end

  def node_existence
    unless content.doc_node
      case state
      when 'public'
        errors.add(:base, '記事コンテンツのディレクトリが作成されていないため、即時公開が行えません。')
      when 'recognize'
        errors.add(:base, '記事コンテンツのディレクトリが作成されていないため、承認依頼が行えません。')
      end
    end
  end

  def validate_platform_dependent_characters
    [:title, :body, :mobile_title, :mobile_body].each do |attr|
      if chars = Util::String.search_platform_dependent_characters(send(attr))
        errors.add attr, :platform_dependent_characters, :chars => chars
      end
    end
  end

  def set_tags
    return tags.clear unless content.tag_content_tag
    all_tags = content.tag_content_tag.tags
    return tags.clear if raw_tags.blank?
    words = raw_tags.split(/[、､，,]/)
    self.tags = words.map do |word|
        all_tags.find_by_word(word) || all_tags.create(word: word)
      end
    self.tags.each {|t| t.update_last_tagged_at }
    all_tags.each {|t| t.destroy if t.docs.empty? }
  end
end
