class Survey::Form < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  CONFIRMATION_OPTIONS = [['あり', true], ['なし', false]]

  default_scope order("#{self.table_name}.sort_no IS NULL, #{self.table_name}.sort_no")

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Survey::Content::Form'
  validates_presence_of :content_id

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  validates_presence_of :state

  has_many :questions, :dependent => :destroy
  has_many :form_answers, :dependent => :destroy

  validates :title, :presence => true

  validate :open_period

  after_initialize :set_defaults
  before_save :set_name

  scope :public, where(state: 'public')

  def public_questions
    questions.public
  end

  def open?
    now = Time.now
    return false if opened_at && opened_at > now
    return false if closed_at && closed_at < now
    return true
  end

  private

  def set_defaults
    self.state        = STATE_OPTIONS.first.last        if self.has_attribute?(:state) && self.state.nil?
    self.confirmation = CONFIRMATION_OPTIONS.first.last if self.has_attribute?(:confirmation) && self.confirmation.nil?
    self.sort_no      = 10 if self.has_attribute?(:sort_no) && self.sort_no.nil?
  end

  def set_name
    return if self.name.present?
    date = if created_at
             created_at.strftime('%Y%m%d')
           else
             Date.strptime(Core.now, '%Y-%m-%d').strftime('%Y%m%d')
           end
    seq = Util::Sequencer.next_id('survey_forms', :version => date)
    self.name = Util::String::CheckDigit.check(date + format('%04d', seq))
  end

  def open_period
    return if opened_at.blank? || closed_at.blank?
    errors.add(:opened_at, "が#{self.class.human_attribute_name :closed_at}を過ぎています。") if closed_at < opened_at
  end
end
