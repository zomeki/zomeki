# encoding: utf-8
class GpCalendar::Event < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::File
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  TARGET_OPTIONS = [['同一ウィンドウ', '_self'], ['別ウィンドウ', '_blank']]
  ORDER_OPTIONS = [['作成日時（降順）', 'created_at_desc'], ['作成日時（昇順）', 'created_at_asc']]
  IMAGE_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCalendar::Content::Event'
  validates_presence_of :content_id

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  validates_presence_of :state

  has_and_belongs_to_many :categories, :class_name => 'GpCategory::Category', :join_table => 'gp_calendar_events_gp_category_categories'

  after_initialize :set_defaults
  before_save :set_name

  validates_presence_of :started_on, :ended_on, :title
  validates :name, :uniqueness => true, :format => {with: /^[\-\w]*$/ }

  validate :dates_range

  scope :public, where(state: 'public')

  def self.all_with_content_and_criteria(content, criteria)
    events = self.arel_table

    rel = self.where(events[:content_id].eq(content.id))
    rel = rel.where(events[:name].matches("%#{criteria[:name]}%")) if criteria[:name].present?
    rel = rel.where(events[:started_on].lteq(criteria[:date])
                    .and(events[:ended_on].gteq(criteria[:date]))) if criteria[:date].present?
    rel = case criteria[:order]
          when 'created_at_desc'
            rel.except(:order).order(events[:created_at].desc)
          when 'created_at_asc'
            rel.except(:order).order(events[:created_at].asc)
          else
            rel
          end

    if /^\d{6}$/ =~ (month = criteria[:month])
      begin
        start_date = Date.new(month.slice(0, 4).to_i, month.slice(4, 2).to_i, 1)
        end_date = start_date.end_of_month
        rel = rel.where(events[:started_on].lteq(end_date)
                        .and(events[:ended_on].gteq(start_date)))
      rescue ArgumentError => e
        warn_log("#{self} #{e.message}")
      end
    end

    return rel
  end

  private

  def set_defaults
    self.state ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
    self.target ||= TARGET_OPTIONS.first.last if self.has_attribute?(:target)
  end

  def set_name
    return if self.name.present?
    date = if created_at
             created_at.strftime('%Y%m%d')
           else
             Date.strptime(Core.now, '%Y-%m-%d').strftime('%Y%m%d')
           end
    seq = Util::Sequencer.next_id('gp_calendar_events', :version => date)
    self.name = Util::String::CheckDigit.check(date + format('%04d', seq))
  end

  def dates_range
    return if self.started_on.blank? && self.ended_on.blank?
    self.started_on = self.ended_on if self.started_on.blank?
    self.ended_on = self.started_on if self.ended_on.blank?
    errors.add(:ended_on, "が#{self.class.human_attribute_name :started_on}を過ぎています。") if self.ended_on < self.started_on
  end
end
