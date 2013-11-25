# encoding: utf-8
class GpArticle::Doc < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::OperationLog
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::EditableGroup
  include Sys::Model::Rel::File
  include Sys::Model::Rel::Task
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask
  include Cms::Model::Rel::ManyInquiry
  include Cms::Model::Rel::Map

  include Cms::Model::Auth::Concept
  include Sys::Model::Auth::EditableGroup

  include GpArticle::Model::Rel::Doc::Rel

  STATE_OPTIONS = [['下書き保存', 'draft'], ['承認依頼', 'approvable'], ['即時公開', 'public']]
  TARGET_OPTIONS = [['無効', ''], ['同一ウィンドウ', '_self'], ['別ウィンドウ', '_blank'], ['添付ファイル', 'attached_file']]
  EVENT_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  MARKER_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]

  default_scope where("#{self.table_name}.state != 'archived'")

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'
  validates_presence_of :content_id

  # Page
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  belongs_to :prev_edition, :class_name => self.name
  has_one :next_edition, :foreign_key => :prev_edition_id, :class_name => self.name

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
  before_save :set_published_at
  before_save :replace_public
  before_destroy :keep_edition_relation

  validates :title, :presence => true, :length => {maximum: 200}
  validates :mobile_title, :length => {maximum: 200}
  validates :body, :length => {maximum: 300000}
  validates :mobile_body, :length => {maximum: 300000}
  validates :state, :presence => true
  validate :name_validity

  validate :validate_inquiry

  #validate :validate_platform_dependent_characters, :unless => :state_draft?
  validate :node_existence
  validate :event_dates_range
  validate :broken_link_existence, :unless => :state_draft?
  validate :body_limit_for_mobile

  #validate :validate_word_dictionary, :unless => :state_draft?
  validate :validate_accessibility_check, :unless => :state_draft?

  after_initialize :set_defaults
  after_save :set_tags
  after_save :set_display_attributes
  after_save :save_links

  attr_accessor :ignore_accessibility_check

  scope :public, where(state: 'public')
  scope :mobile, lambda {|m| m ? where(terminal_mobile: true) : where(terminal_pc_or_smart_phone: true) }
  scope :none, where('id IS ?', nil).where('id IS NOT ?', nil)

  def self.all_with_content_and_criteria(content, criteria)
    docs = self.arel_table

    creators = Sys::Creator.arel_table

    rel = if criteria[:group].blank? && criteria[:group_id].blank? && criteria[:user].blank?
            self.joins(:creator)
          else
            inners = []

            if criteria[:group].present? || criteria[:group_id].present?
              groups = Sys::Group.arel_table
              inners << :group
            end

            if criteria[:user].present?
              users = Sys::User.arel_table
              inners << :user
            end

            self.joins(:creator => inners)
          end

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

    if criteria[:approvable].present?
      approval_requests = Approval::ApprovalRequest.arel_table
      assignments = Approval::Assignment.arel_table
      rel = rel.joins(:approval_requests => [:approval_flow => [:approvals => :assignments]])
               .where(approval_requests[:user_id].eq(Core.user.id)
                      .or(assignments[:user_id].eq(Core.user.id))).uniq
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

  def prev_edition
    self.class.unscoped { super }
  end

  def prev_editions(docs=[])
    docs << self
    prev_edition.prev_editions(docs) if prev_edition
    return docs
  end

  def next_edition
    self.class.unscoped { super }
  end

  def next_editions(docs=[])
    docs << self
    next_edition.next_editions(docs) if next_edition
    return docs
  end

  def raw_tags=(new_raw_tags)
    super (new_raw_tags.nil? ? new_raw_tags : new_raw_tags.to_s.gsub('　', ' '))
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

  def preview_uri(site: nil, mobile: false, params: {})
    return nil unless public_uri
    site ||= ::Page.site
    params = params.map{|k, v| "#{k}=#{v}" }.join('&')
    "#{site.full_uri}_preview/#{format('%08d', site.id)}#{mobile ? 'm' : ''}#{public_uri}preview/#{id}/#{params.present? ? "?#{params}" : ''}"
  end

  def state_options
    options = if Core.user.has_auth?(:manager) || content.save_button_states.include?('public')
                STATE_OPTIONS
              else
                STATE_OPTIONS.reject{|so| so.last == 'public' }
              end
    if content.approval_related?
      options
    else
      options.reject{|o| o.last == 'approvable' }
    end
  end

  def state_draft?
    state == 'draft'
  end

  def state_approvable?
    state == 'approvable'
  end

  def state_approved?
    state == 'approved'
  end

  def state_public?
    state == 'public'
  end

  def state_archived?
    state == 'archived'
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
    self.state = 'public' unless self.state_public?
    return false unless save(:validate => false)
    publish_page(content, path: public_path, uri: public_uri)
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

  def duplicate(dup_for=nil)
    new_attributes = self.attributes

    new_attributes[:state] = 'draft'
    new_attributes[:id] = nil
    new_attributes[:unid] = nil
    new_attributes[:created_at] = nil
    new_attributes[:prev_edition_id] = nil

    new_doc = self.class.new(new_attributes)

    case dup_for
    when :replace
      new_doc.prev_edition = self
    else
      new_doc.name = nil
      new_doc.title = new_doc.title.gsub(/^(【複製】)*/, '【複製】')
    end

    new_doc.in_editable_groups = editable_group.group_ids.split if editable_group

    inquiries.each_with_index do |inquiry, i|
      if i == 0
        attrs = inquiry.attributes
        attrs[:group_id] = Core.user.group_id
        new_doc.inquiries.build(inquiry.attributes)
      else
        new_doc.inquiries.build(inquiry.attributes)
      end
    end

    unless maps.empty?
      new_maps = {}
      maps.each_with_index do |m, i|
        new_markers = {}
        m.markers.each_with_index do |mm, j|
          new_markers[j.to_s] = {
           'name' => mm.name,
           'lat'  => mm.lat,
           'lng'  => mm.lng
          }.with_indifferent_access
        end

        new_maps[i.to_s] = {
          'name'     => m.name,
          'title'    => m.title,
          'map_lat'  => m.map_lat,
          'map_lng'  => m.map_lng,
          'map_zoom' => m.map_zoom,
          'markers'  => new_markers
        }.with_indifferent_access
      end
      new_doc.in_maps = new_maps
    end

    new_doc.save!

    files.each do |f|
      Sys::File.new(f.attributes).tap do |new_file|
        new_file.file = Sys::Lib::File::NoUploadedFile.new(f.upload_path)
        new_file.unid = nil
        new_file.parent_unid = new_doc.unid
        new_file.save
      end
    end

    new_doc.categories = self.categories
    new_doc.event_categories = self.event_categories
    new_doc.marker_categories = self.marker_categories

    return new_doc
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

  def send_approval_request_mail
    subject = "#{content.name}（#{content.site.name}）：承認依頼メール"

    approval_requests.each do |approval_request|
      body = <<-EOT
#{approval_request.requester.name}さんより「#{title}」についての承認依頼が届きました。
  次の手順により，承認作業を行ってください。

  １．PC用記事のプレビューにより文書を確認
    #{preview_uri(site: content.site)}
  ２．次のリンクから承認を実施
    #{content.site.full_uri.sub(/\/+$/, '')}#{Rails.application.routes.url_helpers.gp_article_doc_path(content: content, id: id, active_tab: 'approval')}
      EOT

      approval_request.current_assignments.map{|a| a.user unless a.approved_at }.compact.each do |approver|
        next if approval_request.requester.email.blank? || approver.email.blank?
        CommonMailer.plain(from: approval_request.requester.email, to: approver.email, subject: subject, body: body).deliver
      end
    end
  end

  def send_approved_notification_mail
    subject = "#{content.name}（#{content.site.name}）：承認完了メール"

    approval_requests.each do |approval_request|
      next unless approval_request.finished?

      body = <<-EOT
「#{title}」についての承認が完了しました。
  次のＵＲＬをクリックして公開処理を行ってください。
  #{content.site.full_uri.sub(/\/+$/, '')}#{Rails.application.routes.url_helpers.gp_article_doc_path(content: content, id: id, active_tab: 'approval')}
      EOT

      approver = approval_request.current_assignments.reorder('approved_at DESC').first.user
      next if approver.email.blank? || approval_request.requester.email.blank?
      CommonMailer.plain(from: approver.email, to: approval_request.requester.email, subject: subject, body: body).deliver
    end
  end

  def send_passbacked_notification_mail(approval_request: nil, approver: nil, comment: '')
    return if approver.email.blank? || approval_request.requester.email.blank?

    detail_url = "#{content.site.full_uri.sub(/\/+$/, '')}#{Rails.application.routes.url_helpers.gp_article_doc_path(content: content, id: id, active_tab: 'approval')}"

    CommonMailer.passbacked_notification(approval_request: approval_request, approver: approver, comment: comment, detail_url: detail_url,
                                         from: approver.email, to: approval_request.requester.email).deliver
  end

  def send_pullbacked_notification_mail(approval_request: nil, comment: '')
    detail_url = "#{content.site.full_uri.sub(/\/+$/, '')}#{Rails.application.routes.url_helpers.gp_article_doc_path(content: content, id: id, active_tab: 'approval')}"

    approval_request.current_approvers.each do |approver|
      next if approver.email.blank? || approval_request.requester.email.blank?
      CommonMailer.pullbacked_notification(approval_request: approval_request, comment: comment, detail_url: detail_url,
                                           from: approval_request.requester.email, to: approver.email).deliver
    end
  end

  def approvers
    approval_requests.inject([]){|u, r| u | r.current_assignments.map{|a| a.user unless a.approved_at }.compact }
  end

  def approval_requesters
    approval_requests.inject([]){|u, r| u.include?(r.requester) ? u : u.push(r.requester) }
  end

  def approval_participators
    users = []
    approval_requests.each do |approval_request|
      users << approval_request.requester
      approval_request.approval_flow.approvals.each do |approval|
        users.concat(approval.approvers)
      end
    end
    return users.uniq
  end

  def approve(user)
    return unless state_approvable?

    approval_requests.each do |approval_request|
      approval_request.approve(user) do |state|
        case state
        when 'progress'
          send_approval_request_mail
        when 'finish'
          send_approved_notification_mail
        end
      end
    end

    update_column(:state, 'approved') if approval_requests.all?{|r| r.finished? }
  end

  def passback(approver, comment: '')
    return unless state_approvable?
    approval_requests.each do |approval_request|
      send_passbacked_notification_mail(approval_request: approval_request,
                                        approver: approver,
                                        comment: comment)
      approval_request.passback(approver, comment: comment)
    end
    update_column(:state, 'draft')
  end

  def pullback(comment: '')
    return unless state_approvable?
    approval_requests.each do |approval_request|
      send_pullbacked_notification_mail(approval_request: approval_request,
                                        comment: comment)
      approval_request.pullback(comment: comment)
    end
    update_column(:state, 'draft')
  end

  def validate_word_dictionary
    dic = content.setting_value(:word_dictionary)
    return if dic.blank?

    words = []
    dic.split(/\r\n|\n/).each do |line|
      next if line !~ /,/
      data = line.split(/,/)
      words << [data[0].strip, data[1].strip]
    end

    if body.present?
      words.each {|src, dst| self.body = body.gsub(src, dst) }
    end
    if mobile_body.present?
      words.each {|src, dst| self.mobile_body = mobile_body.gsub(src, dst) }
    end
  end

  def body_for_mobile
    body_doc = Nokogiri::XML("<bory_root>#{self.mobile_body.presence || self.body}</bory_root>")
    body_doc.xpath('//img').each {|img| img.replace(img.attribute('alt').try(:value).to_s) }
    body_doc.xpath('//a').each {|a| a.replace(a.text) if a.attribute('href').try(:value) =~ %r!^file_contents/! }
    body_doc.xpath('/bory_root').to_xml.gsub(%r!^<bory_root>|</bory_root>$!, '')
  end

  def will_replace?
    prev_edition && (state_draft? || state_approvable? || state_approved?)
  end

  def will_be_replaced?
    next_edition && state_public?
  end

  def was_replaced?
    prev_edition && state_public?
  end

  private

  def name_validity
    if prev_edition
      self.name = prev_edition.name
      return
    end

    errors.add(:name, :invalid) if self.name && self.name !~ /^[\-\w]*$/

    if (doc = self.class.find_by_name_and_state(self.name, self.state))
      unless doc.id == self.id || state_archived?
        errors.add(:name, :taken) unless state_public? && prev_edition.try(:state_public?)
      end
    end
  end

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

  def set_published_at
    self.published_at ||= Core.now if self.state == 'public'
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
      when 'approvable'
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

  def validate_accessibility_check
    check_results = Util::AccessibilityChecker.check body

    if check_results != [] && !ignore_accessibility_check
     errors.add(:base, 'アクセシビリティチェック結果を確認してください')
    end
  end

  def body_limit_for_mobile
    limit = Zomeki.config.application['gp_article.body_limit_for_mobile'].to_i
    current_size = self.body_for_mobile.bytesize
    if current_size > limit
      target = self.mobile_body.present? ? :mobile_body : :body
      errors.add(target, "が携帯向け容量制限#{limit}バイトを超えています。（現在#{current_size}バイト）")
    end
  end

  def replace_public
    return unless state_public?
    prev_edition.try(:update_column, :state, 'archived')
    if (pe = prev_editions).size > 4 # Include self
      pe.last.destroy
    end
  end

  def keep_edition_relation
    next_edition.update_column(:prev_edition_id, prev_edition_id) if next_edition
    return true
  end
end
