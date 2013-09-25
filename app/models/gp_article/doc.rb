# encoding: utf-8
class GpArticle::Doc < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::OperationLog
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
  include Cms::Model::Rel::ManyInquiry
  include Cms::Model::Rel::Map

  include Cms::Model::Auth::Concept
  include Sys::Model::Auth::EditableGroup

  include GpArticle::Model::Rel::Doc::Rel

  STATE_OPTIONS = [['下書き保存', 'draft'], ['承認依頼', 'recognize'], ['即時公開', 'public']]
  TARGET_OPTIONS = [['無効', ''], ['同一ウィンドウ', '_self'], ['別ウィンドウ', '_blank'], ['添付ファイル', 'attached_file']]
  EVENT_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  MARKER_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'
  validates_presence_of :content_id

  # Page
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  has_many :categorizations, :class_name => 'GpCategory::Categorization', :as => :categorizable, :dependent => :destroy
  has_many :categories, :class_name => 'GpCategory::Category', :through => :categorizations,
           :conditions => ["#{GpCategory::Categorization.table_name}.categorized_as = ?", self.name],
           :after_add => proc {|d, c| d.categorizations.find_by_category_id(c.id).update_column(:categorized_as, d.class.name) }
  has_many :event_categories, :class_name => 'GpCategory::Category', :through => :categorizations,
           :source => :category, :conditions => ["#{GpCategory::Categorization.table_name}.categorized_as = ?", 'GpCalendar::Event'],
           :after_add => proc {|d, c| d.categorizations.find_by_category_id(c.id).update_column(:categorized_as, 'GpCalendar::Event') }
  has_many :marker_categories, :class_name => 'GpCategory::Category', :through => :categorizations,
           :source => :category, :conditions => ["#{GpCategory::Categorization.table_name}.categorized_as = ?", 'Map::Marker'],
           :after_add => proc {|d, c| d.categorizations.find_by_category_id(c.id).update_column(:categorized_as, 'Map::Marker') }
  has_and_belongs_to_many :tags, :class_name => 'Tag::Tag', :join_table => 'gp_article_docs_tag_tags',
                          :conditions => proc { self.content.try(:tag_content_tag) ? ['content_id = ?', self.content.tag_content_tag.id] : 'FALSE' }
  has_many :holds, :as => :holdable, :dependent => :destroy
  has_many :links, :dependent => :destroy
  has_many :approval_requests, :class_name => 'Approval::ApprovalRequest', :as => :approvable, :dependent => :destroy

  before_save :make_file_contents_path_relative
  before_save :set_name

  validates :title, :presence => true, :length => {maximum: 200}
  validates :mobile_title, :length => {maximum: 200}
  validates :body, :length => {maximum: 300000}
  validates :mobile_body, :length => {maximum: 300000}
  validates :state, :presence => true
  validates :name, :uniqueness => true, :format => {with: /^[\-\w]*$/ }

  validate :validate_inquiry
  validate :validate_recognizers, :if => :state_recognize?

  validate :validate_platform_dependent_characters, :unless => :state_draft?
  validate :node_existence
  validate :event_dates_range
  validate :broken_link_existence, :unless => :state_draft?

  after_initialize :set_defaults
  after_save :set_tags
  after_save :set_display_attributes
  after_save :save_links

  scope :public, where(state: 'public')
  scope :mobile, lambda {|m| m ? where(terminal_mobile: true) : where(terminal_pc_or_smart_phone: true) }
  scope :none, where('id IS ?', nil).where('id IS NOT ?', nil)

  def self.all_with_content_and_criteria(content, criteria)
    docs = self.arel_table

    creators = Sys::Creator.arel_table
    groups = Sys::Group.arel_table
    users = Sys::User.arel_table

    rel = self.joins(:creator => [:group, :user])

    rel = rel.where(docs[:content_id].eq(content.id)) if content.is_a?(GpArticle::Content::Doc)

    rel = rel.where(docs[:id].eq(criteria[:id])) if criteria[:id].present?
    rel = rel.where(docs[:state].eq(criteria[:state])) if criteria[:state].present?
    rel = rel.where(docs[:title].matches("%#{criteria[:title]}%")) if criteria[:title].present?
    rel = rel.where(docs[:title].matches("%#{criteria[:free_word]}%")
                    .or(docs[:body].matches("%#{criteria[:free_word]}%"))
                    .or(docs[:name].matches("%#{criteria[:free_word]}%"))) if criteria[:free_word].present?
    rel = rel.where(groups[:name].matches("%#{criteria[:group]}%")) if criteria[:group].present?
    rel = rel.where(groups[:id].eq(criteria[:group_id])) if criteria[:group_id].present?
    rel = rel.where(users[:name].matches("%#{criteria[:user]}%")
                    .or(users[:name_en].matches("%#{criteria[:user]}%"))) if criteria[:user].present?

    if criteria[:touched_user_id].present?
      operation_logs = Sys::OperationLog.arel_table

      rel = rel.includes(:operation_logs).where(operation_logs[:user_id].eq(criteria[:touched_user_id])
                                                .or(creators[:user_id].eq(criteria[:touched_user_id])))
    end

    if criteria[:editable].present?
      editable_groups = Sys::EditableGroup.arel_table

      rel = unless Core.user.has_auth?(:manager)
              rel.includes(:editable_group).where(creators[:group_id].eq(Core.user.group.id)
                                                  .or(editable_groups[:group_ids].eq(Core.user.group.id.to_s)
                                                  .or(editable_groups[:group_ids].matches("#{Core.user.group.id} %")
                                                  .or(editable_groups[:group_ids].matches("% #{Core.user.group.id} %")
                                                  .or(editable_groups[:group_ids].matches("% #{Core.user.group.id}"))))))
            else
              rel
            end
    end

    if criteria[:recognizable].present?
      recognitions = Sys::Recognition.arel_table

      rel = if content.setting_value(:recognition_type) == 'with_admin' && Core.user.has_auth?(:manager)
              rel.joins(:recognition).where(creators[:user_id].eq(Core.user.id)
                                            .or(recognitions[:user_id].eq(Core.user.id))
                                            .or(recognitions[:recognizer_ids].eq(Core.user.id.to_s)
                                            .or(recognitions[:recognizer_ids].matches("#{Core.user.id} %")
                                            .or(recognitions[:recognizer_ids].matches("% #{Core.user.id} %")
                                            .or(recognitions[:recognizer_ids].matches("% #{Core.user.id}")
                                            .or(recognitions[:info_xml].matches("%<admin %")))))))
            else
              rel.joins(:recognition).where(creators[:user_id].eq(Core.user.id)
                                            .or(recognitions[:user_id].eq(Core.user.id))
                                            .or(recognitions[:recognizer_ids].eq(Core.user.id.to_s)
                                            .or(recognitions[:recognizer_ids].matches("#{Core.user.id} %")
                                            .or(recognitions[:recognizer_ids].matches("% #{Core.user.id} %")
                                            .or(recognitions[:recognizer_ids].matches("% #{Core.user.id}"))))))
            end
    end

    if criteria[:category_id].present?
      cats = GpCategory::Categorization.arel_table

      conditions = if criteria[:category_id].is_a?(Array)
                     cats[:category_id].in(criteria[:category_id])
                   else
                     cats[:category_id].eq(criteria[:category_id])
                   end

      rel = rel.joins(:categorizations).where(conditions).order(cats[:sort_no].eq(nil), cats[:sort_no].asc)
    end

    return rel
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

      case key.to_s
      when 's_id'
        self.and "#{GpArticle::Doc.table_name}.id", value.to_i
      when 's_title'
        self.and_keywords value, :title
      when 's_group'
        self.join :creator
        self.join "INNER JOIN #{Sys::Group.table_name} ON #{Sys::Group.table_name}.id = #{Sys::Creator.table_name}.group_id"
        self.and "#{Sys::Group.table_name}.name", 'LIKE', "%#{value}%"
      when 's_group_id'
        self.join :creator
        self.join "INNER JOIN #{Sys::Group.table_name} ON #{Sys::Group.table_name}.id = #{Sys::Creator.table_name}.group_id"
        self.and "#{Sys::Group.table_name}.id", value.to_i
      when 's_user'
        self.join :creator
        self.join "INNER JOIN #{Sys::User.table_name} ON #{Sys::User.table_name}.id = #{Sys::Creator.table_name}.user_id"
        self.and "#{Sys::User.table_name}.name", 'LIKE', "%#{value}%"
      when 's_free_word'
        self.and(Condition.new) do |c|
          c.or 'title', 'LIKE', "%#{value}%"
          c.or 'body', 'LIKE', "%#{value}%"
          c.or 'name', 'LIKE', "%#{value}%"
        end
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

    inquiries.each do |inquiry|
      if inquiry.try(:group_id) == Core.user.group_id
        item.inquiries.build(inquiry.attributes)
      else
        attrs = inquiry.attributes
        attrs[:group_id] = Core.user.group_id
        item.inquiries.build(attrs)
      end
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

  def formated_display_published_at
    display_published_at.try(:strftime, content.date_style)
  end

  def formated_display_updated_at
    display_updated_at.try(:strftime, content.date_style)
  end

  def default_map_position
    content.setting_extra_value(:map_relation, :lat_lng).presence || super
  end

  def links_in_body(all=false)
    extract_links(self.body, all)
  end

  def check_links_in_body
    check_results = check_links(links_in_body)
    @broken_link_exists_in_body = check_results.any? {|r| !r[:result] }
    return check_results
  end

  def links_in_mobile_body(all=false)
    extract_links(self.mobile_body, all)
  end

  def broken_link_exists?
    @broken_link_exists_in_body
  end

  def backlinks
    links.engine.where(links.table[:url].matches("%#{self.public_uri.sub(/\/$/, '')}%"))
  end

  def backlinked_docs
    self.class.where(id: backlinks.pluck(:doc_id))
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
    self.target       ||= TARGET_OPTIONS.first.last if self.has_attribute?(:target)
    self.event_state  ||= 'hidden'                  if self.has_attribute?(:event_state)
    self.marker_state ||= 'hidden'                  if self.has_attribute?(:marker_state)
    self.terminal_pc_or_smart_phone = true if self.has_attribute?(:terminal_pc_or_smart_phone) && self.terminal_pc_or_smart_phone.nil?
    self.terminal_mobile            = true if self.has_attribute?(:terminal_mobile) && self.terminal_mobile.nil?
  end

  def set_display_attributes
    self.update_column(:display_published_at, self.published_at) unless self.display_published_at
    self.update_column(:display_updated_at, self.updated_at) unless self.display_updated_at
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

  def event_dates_range
    return if self.event_started_on.blank? && self.event_ended_on.blank?
    self.event_started_on = self.event_ended_on if self.event_started_on.blank?
    self.event_ended_on = self.event_started_on if self.event_ended_on.blank?
    errors.add(:event_ended_on, "が#{self.class.human_attribute_name :event_started_on}を過ぎています。") if self.event_ended_on < self.event_started_on
  end

  def extract_links(html, all)
    links = Nokogiri::HTML.parse(html).css('a').map {|a| {body: a.text, url: a.attribute('href').value} }
    return links if all
    links.select do |link|
      uri = URI.parse(link[:url])
      next true unless uri.absolute?
      [URI::HTTP, URI::HTTPS, URI::FTP].include?(uri.class)
    end
  rescue => evar
    warn_log evar.message
    return []
  end

  def check_links(links)
    links.map{|link|
      uri = URI.parse(link[:url])
      url = unless uri.absolute?
              next unless uri.path =~ /^\//
              "#{content.site.full_uri.sub(/\/$/, '')}#{uri.path}"
            else
              uri.to_s
            end

      res = Util::LinkChecker.check_url(url)
      {body: link[:body], url: url, status: res[:status], reason: res[:reason], result: res[:result]}
    }.compact
  end

  def broken_link_existence
    errors.add(:base, 'リンクチェック結果を確認してください。') if broken_link_exists?
  end

  def save_links
    lib = links_in_body
    links.each do |link|
      link.destroy unless lib.detect {|l| l[:body] == link.body && l[:url] == link.url }
    end
    lib.each do |link|
      links.create(body: link[:body], url: link[:url]) unless links.find_by_body_and_url(link[:body], link[:url])
    end
  end
end
