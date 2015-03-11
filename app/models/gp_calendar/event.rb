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
  WILL_SYNC_OPTIONS = [['同期しない', 'no'], ['同期する', 'yes']]

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

  scope :public, -> { where(state: 'public') }
  scope :none, -> { where("#{self.table_name}.id IS NULL").where("#{self.table_name}.id IS NOT NULL") }

  def self.all_with_content_and_criteria(content, criteria)
    events = self.arel_table

    rel = self.where(events[:content_id].eq(content.id))
    rel = if criteria[:synced]
            rel.where(events[:sync_source_host].not_eq(nil))
          else
            rel.where(events[:sync_source_host].eq(nil))
          end
    rel = rel.where(events[:name].matches("%#{criteria[:name]}%")) if criteria[:name].present?
    rel = rel.where(events[:title].matches("%#{criteria[:title]}%")) if criteria[:title].present?
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

    if (year_month = criteria[:year_month]) =~ /^(\d{6}|\d{4})$/
      case year_month
      when /^\d{6}$/
        start_date = Date.new(year_month.slice(0, 4).to_i, year_month.slice(4, 2).to_i, 1)
        end_date = start_date.end_of_month
      when /^\d{4}$/
        start_date = Date.new(year_month.to_i, 1, 1)
        end_date = start_date.end_of_year
      end

      if start_date && end_date
        rel = rel.where(events[:started_on].lteq(end_date)
                        .and(events[:ended_on].gteq(start_date)))
      end
    end

    return rel
  end

  belongs_to :doc, :class_name => 'GpArticle::Doc' # Not saved to database

  def holiday
    criteria = {date: started_on, kind: 'holiday'}
    GpCalendar::Holiday.public.all_with_content_and_criteria(content, criteria).first.title rescue nil
  end

  def public_path
    node = content.public_nodes.where(model: 'GpCalendar::Event').first
    return '' unless node
    "#{node.public_path}#{name}"
  end

  def public_files_path
    return '' if public_path.blank?
    "#{public_path}/file_contents"
  end

  def publish_files
    return if public_files_path.blank?
    @save_mode = :publish
    super
  end

  def close_files
    @save_mode = :close
    super
  end

  def publish!
    update_attribute(:state, 'public')
  end

  def close!
    update_attribute(:state, 'closed')
  end

  def will_sync?
    will_sync == 'yes'
  end

  def will_sync_text
    WILL_SYNC_OPTIONS.detect{|o| o.last == will_sync }.try(:first).to_s
  end

  private

  def set_defaults
    self.state ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
    self.target ||= TARGET_OPTIONS.first.last if self.has_attribute?(:target)
    self.will_sync ||= WILL_SYNC_OPTIONS.first.last if self.has_attribute?(:will_sync)
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
