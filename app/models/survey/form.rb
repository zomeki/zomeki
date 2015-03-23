class Survey::Form < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::OperationLog
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::EditableGroup

  include Cms::Model::Auth::Concept
  include Sys::Model::Auth::EditableGroup

  STATE_OPTIONS = [['下書き保存', 'draft'], ['承認依頼', 'approvable'], ['即時公開', 'public']]
  CONFIRMATION_OPTIONS = [['あり', true], ['なし', false]]
  SITEMAP_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  INDEX_LINK_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]

  default_scope order("#{self.table_name}.sort_no IS NULL, #{self.table_name}.sort_no")

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Survey::Content::Form'
  validates_presence_of :content_id

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  validates_presence_of :state

  has_many :questions, :dependent => :destroy
  has_many :form_answers, :dependent => :destroy
  has_many :approval_requests, :class_name => 'Approval::ApprovalRequest', :as => :approvable, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => {:scope => :content_id}, :format => {with: /^[-\w]*$/}
  validates :title, :presence => true

  validate :open_period

  after_initialize :set_defaults

  scope :public, where(state: 'public')

  def self.all_with_content_and_criteria(content, criteria)
    forms = self.arel_table

    rel = self.where(forms[:content_id].eq(content.id))
    rel = rel.where(forms[:state].eq(criteria[:state])) if criteria[:state].present?

    if criteria[:touched_user_id].present? || criteria[:editable].present?
      creators = Sys::Creator.arel_table
      rel = rel.joins(:creator)
    end

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

    return rel
  end

  def public_questions
    questions.public
  end

  def automatic_reply?
    return true if automatic_reply_question
    false
  end

  def automatic_reply_question
    public_questions.each do |q|
      return q if q.email_field?
    end
    return nil
  end

  def open?
    now = Time.now
    return false if opened_at && opened_at > now
    return false if closed_at && closed_at < now
    return true
  end

  def state_options
    options = STATE_OPTIONS
    options.reject!{|o| o.last == 'public' } unless Core.user.has_auth?(:manager)
    options.reject!{|o| o.last == 'approvable' } unless content.approval_related?
    return options
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

  def send_approval_request_mail

    _core_uri = Cms::SiteSetting::AdminProtocol.core_domain content.site, content.site.full_uri

    approve_url = "#{_core_uri.sub(/\/+$/, '')}#{Rails.application.routes.url_helpers.survey_form_path(content: content, id: id)}"
    preview_url = self.preview_uri

    approval_requests.each do |approval_request|
      approval_request.current_assignments.map{|a| a.user unless a.approved_at }.compact.each do |approver|
        next if approval_request.requester.email.blank? || approver.email.blank?
        CommonMailer.approval_request(approval_request: approval_request, preview_url: preview_url, approve_url: approve_url,
                                      from: approval_request.requester.email, to: approver.email).deliver
      end
    end
  end

  def send_approved_notification_mail

    _core_uri = Cms::SiteSetting::AdminProtocol.core_domain content.site, content.site.full_uri

    publish_url = "#{_core_uri.sub(/\/+$/, '')}#{Rails.application.routes.url_helpers.survey_form_path(content: content, id: id)}"

    approval_requests.each do |approval_request|
      next unless approval_request.finished?

      approver = approval_request.current_assignments.reorder('approved_at DESC').first.user
      next if approver.email.blank? || approval_request.requester.email.blank?
      CommonMailer.approved_notification(approval_request: approval_request, publish_url: publish_url,
                                         from: approver.email, to: approval_request.requester.email).deliver
    end
  end

  def approvers
    approval_requests.inject([]){|u, r| u | r.current_assignments.map{|a| a.user unless a.approved_at }.compact }
  end

  def approval_participators
    users = [creator.user]
    approval_requests.each do |approval_request|
      users << approval_request.requester
      approval_request.approval_flow.approvals.each do |approval|
        _approvers = approval.approvers
        ids = approval_request.select_assignments_ids(approval)
        _approvers = _approvers.select{|a| ids.index(a.id.to_s)} if approval.select_approve?
        users.concat(_approvers)
      end
    end
    return users.uniq
  end

  def approve(user, request=nil)
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

    if approval_requests.all?{|r| r.finished? }
      update_column(:state, 'approved')
      Sys::OperationLog.log(request, :item => self) unless request.blank?
    end
  end

  def duplicate
    item = self.class.new(self.attributes)
    item.id            = nil
    item.unid          = nil
    item.created_at    = nil
    item.updated_at    = nil

    item.name  = nil
    item.title = item.title.gsub(/^(【複製】)*/, "【複製】")
    item.state = "draft"

    return false unless item.save(:validate => false)

    # piece_settings
    questions.each do |question|
      dupe_question = Survey::Question.new(question.attributes)
      dupe_question.form_id   = item.id
      dupe_question.created_at = nil
      dupe_question.updated_at = nil
      dupe_question.save(:validate => false)
    end

    return item
  end

  def publish
    return unless state_approved?
    approval_requests.destroy_all
    update_column(:state, 'public')
  end

  def close
    return unless state_public?
    update_column(:state, 'closed')
  end

  def public_uri
    return nil unless content.public_node
    "#{content.public_node.public_uri}#{name}"
  end

  def preview_uri(site: nil, mobile: false, params: {})
    return nil unless public_uri
    site ||= ::Page.site
    params = params.map{|k, v| "#{k}=#{v}" }.join('&')
    path = "_preview/#{format('%08d', site.id)}#{mobile ? 'm' : ''}#{public_uri}#{params.present? ? "?#{params}" : ''}"

    d = Cms::SiteSetting::AdminProtocol.core_domain site, site.full_uri, :freeze_protocol => true
    "#{d}#{path}"
  end

  def sitemap_visible?
    self.sitemap_state == 'visible'
  end

  def index_visible?
    self.index_link != 'hidden'
  end

  private

  def set_defaults
    self.state        = STATE_OPTIONS.first.last        if self.has_attribute?(:state) && self.state.nil?
    self.confirmation = CONFIRMATION_OPTIONS.first.last if self.has_attribute?(:confirmation) && self.confirmation.nil?
    self.sitemap_state = SITEMAP_STATE_OPTIONS.first.last if self.has_attribute?(:sitemap_state) && self.sitemap_state.nil?
    self.sort_no      = 10 if self.has_attribute?(:sort_no) && self.sort_no.nil?
  end

  def open_period
    return if opened_at.blank? || closed_at.blank?
    errors.add(:opened_at, "が#{self.class.human_attribute_name :closed_at}を過ぎています。") if closed_at < opened_at
  end
end
