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
  include Cms::Model::Base::Page::TalkTask
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
  before_save :make_file_contents_path_relative

  validates :title, :presence => true, :length => {maximum: 200}
  validates :mobile_title, :length => {maximum: 200}
  validates :body, :length => {maximum: 300000}
  validates :mobile_body, :length => {maximum: 300000}
  validates :state, :presence => true

  validate :validate_inquiry
  validate :validate_recognizers, :if => :state_recognize?
  validate :validate_platform_dependent_characters

  validate :node_existence

  after_initialize :set_defaults
  after_save :set_tags

  scope :public, where(state: 'public')
  scope :mobile, lambda {|m| m ? where(terminal_mobile: true) : where(terminal_pc_or_smart_phone: true) }

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

  def public_path
    if name =~ /^[0-9]{13}$/
      _name = name.gsub(/^((\d{4})(\d\d)(\d\d)(\d\d)(\d\d).*)$/, '\2/\3/\4/\5/\6/\1')
    else
      _name = ::File.join(name[0..0], name[0..1], name[0..2], name)
    end
    "#{content.public_path}/docs/#{_name}/index.html"
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
    if Core.user.has_auth?(:manager) || content.save_button_states.include?('public')
      STATE_OPTIONS
    else
      STATE_OPTIONS.reject {|so| so.last == 'public' }
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

    categories.public.each do |category|
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

  def duplicate(rel_type=nil)
    new_attributes = self.attributes

    new_attributes[:id] = nil
    new_attributes[:unid] = nil
    new_attributes[:created_at] = nil
    new_attributes[:updated_at] = nil
    new_attributes[:recognized_at] = nil
    new_attributes[:published_at] = nil
    new_attributes[:state] = 'draft'

    item = self.class.new(new_attributes)

    if rel_type.nil?
      item.name = nil
      item.title = item.title.gsub(/^(【複製】)*/, '【複製】')
    end

    item.in_recognizer_ids  = recognition.recognizer_ids if recognition
    item.in_editable_groups = editable_group.group_ids.split(' ') if editable_group

    if inquiry.try(:group_id) == Core.user.group_id
      item.in_inquiry = inquiry.attributes
    else
      item.in_inquiry = {:group_id => Core.user.group_id}
    end

    unless maps.empty?
      _maps = {}
      maps.each do |m|
        _maps[m.name] = m.in_attributes.symbolize_keys
        _maps[m.name][:markers] = {}
        m.markers.each_with_index{|mm, key| _maps[m.name][:markers][key] = mm.attributes.symbolize_keys}
      end
      item.in_maps = _maps
    end

    return nil unless item.save

    files.each do |f|
      file = Sys::File.new(f.attributes)
      file.file = Sys::Lib::File::NoUploadedFile.new(f.upload_path)
      file.unid = nil
      file.parent_unid = item.unid
      file.save
    end

    item.categories = self.categories

    if rel_type == :replace
      rel = Sys::UnidRelation.new
      rel.unid = item.unid
      rel.rel_unid = self.unid
      rel.rel_type = 'replace'
      rel.save
    end

    return item
  end

  def editable?
    result = super
    return result unless result.nil? # See "Sys::Model::Auth::EditableGroup"
    return editable_group.all?
  end

  private

  def set_name
    return if self.name.present?
    date = if created_at
             created_at.strftime('%Y%m%d')
           else
             Date.strptime(Core.now, '%Y-%m-%d').strftime('%Y%m%d')
           end
    seq = Util::Sequencer.next_id('gp_article_docs', :version => date)
    self.name = Util::String::CheckDigit.check(date + format('%04d', seq))
  end

  def set_defaults
    self.target      ||= TARGET_OPTIONS.first.last if self.has_attribute?(:target)
    self.event_state ||= 'hidden'                  if self.has_attribute?(:event_state)
    self.terminal_pc_or_smart_phone = true if self.has_attribute?(:terminal_pc_or_smart_phone) && self.terminal_pc_or_smart_phone.nil?
    self.terminal_mobile            = true if self.has_attribute?(:terminal_mobile) && self.terminal_mobile.nil?
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

    words = Moji.normalize_zen_han(raw_tags).downcase.split(/[、,]/).map{|w| w.presence }.compact.uniq
    self.tags = words.map do |word|
        all_tags.find_by_word(word) || all_tags.create(word: word)
      end
    self.tags.each {|t| t.update_last_tagged_at }

    all_tags.each {|t| t.destroy if t.public_docs.empty? }
  end

  def make_file_contents_path_relative
    self.body = self.body.gsub(%r|"[^"]*?/(file_contents/)|, '"\1') if self.body.present?
    self.mobile_body = self.mobile_body.gsub(%r|"[^"]*?/(file_contents/)|, '"\1') if self.mobile_body.present?
  end
end
