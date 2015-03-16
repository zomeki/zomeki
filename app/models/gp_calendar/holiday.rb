# encoding: utf-8
class GpCalendar::Holiday < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::File
  include Cms::Model::Auth::Content

  include GpCalendar::EventSync

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  KIND_OPTIONS = [['休日', 'holiday'], ['イベント', 'event']]
  ORDER_OPTIONS = [['作成日時（降順）', 'created_at_desc'], ['作成日時（昇順）', 'created_at_asc']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCalendar::Content::Event'
  validates_presence_of :content_id

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  validates_presence_of :state

  after_initialize :set_defaults

  validates_presence_of :title

  scope :public, -> { where(state: 'public') }

  def self.all_with_content_and_criteria(content, criteria)
    holidays = self.arel_table

    rel = self.where(holidays[:content_id].eq(content.id))
    rel = rel.where(holidays[:title].matches("%#{criteria[:title]}%")) if criteria[:title].present?
    rel = rel.where("date_format(`date`, '%m%d') = ? and ( (ifnull(`repeat`, 0) = 0 and date_format(`date`, '%Y') = ?) or (`repeat` = 1) )", "#{criteria[:date].strftime('%m%d')}", "#{criteria[:date].strftime('%Y')}") if criteria[:date].present?
    rel = rel.where(holidays[:kind].eq(criteria[:kind])) if criteria[:kind].present?
    rel = case criteria[:order]
          when 'created_at_desc'
            rel.except(:order).order(holidays[:created_at].desc)
          when 'created_at_asc'
            rel.except(:order).order(holidays[:created_at].asc)
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
        rel = rel.where("(ifnull(`repeat`, 0) = 0 and date_format(`date`, '%Y%m%d') >= ? and date_format(`date`, '%Y%m%d') <= ?) or (`repeat` = 1 and date_format(`date`, '%m%d') >= ? and date_format(`date`, '%m%d') <= ?)", "#{start_date.strftime('%Y%m%d')}", "#{end_date.strftime('%Y%m%d')}", "#{start_date.strftime('%m%d')}", "#{end_date.strftime('%m%d')}")
      end
    end

    return rel
  end

  belongs_to :doc, :class_name => 'GpArticle::Doc' # Not saved to database

  def started_on=(year)
    @started_on = Date.new(year, self.date.month, self.date.day) if self.date.present?
  end

  def started_on
    @started_on
  end

  def ended_on
    self.started_on
  end

  attr_accessor :href, :name, :categories  # Similarly to event

  def holiday
    criteria = {date: started_on, kind: 'holiday'}
    GpCalendar::Holiday.public.all_with_content_and_criteria(content, criteria).first.title rescue nil
  end

  def publish!
    update_attribute(:state, 'public')
  end

  def close!
    update_attribute(:state, 'closed')
  end

  private

  def set_defaults
    self.state ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
  end

end
