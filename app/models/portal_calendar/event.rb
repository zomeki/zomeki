# encoding: utf-8
class PortalCalendar::Event < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
	belongs_to :genre, :class_name => 'PortalCalendar::Genre', :foreign_key => :genre_id
	belongs_to :event_status, :class_name => 'PortalCalendar::Status', :foreign_key => :status_id

	validates_presence_of :state, :event_start_date, :event_end_date, :title
	validate :period_check?
	
private
	def period_check?
		errors.add(:event_end_date, 'は開始日以降を設定してください。') unless event_end_date >= event_start_date
	end
	
public
	
	#指定の期間に登録されているレコードを一覧取得する（content_idでの絞り込みも行う）
	def self.get_period_records_with_content_id(content_id, sdate, edate)
		self.get_period_records(sdate, edate).where(:content_id => content_id)
	end
	
	#指定の期間に登録されているレコードを一覧取得する
	def self.get_period_records(sdate, edate)
		self.where('event_start_date <= ? AND event_end_date >= ?', edate, sdate).order('event_start_date ASC, id ASC')
	end

	#イベントのジャンルリストの取得
	def self.get_genre_valid_list(content_id)
		return get_genre_list(content_id, :only_valid => true)
	end

	#イベントのジャンルリストの取得
	def self.get_genre_list(content_id, options={})
		list = PortalCalendar::Genre.where(:content_id => content_id)
		return options[:only_valid] ? list.where(:state => 'public') : list
	end

	#イベントのステータスリストの取得
	def self.get_status_valid_list(content_id)
		return get_status_list(content_id, :only_valid => true)
	end

	#イベントのステータスリストの取得
	def self.get_status_list(content_id, options={})
		list = PortalCalendar::Status.where(:content_id => content_id)
		return options[:only_valid] ? list.where(:state => 'public') : list
	end
	
	def get_genre_title
		begin
			self.genre.title
		rescue
			self.locale(:invalid)
		end
	end
	
	def get_status_title
		begin
			self.event_status.title
		rescue
			self.locale(:invalid)
		end
	end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_event_date'
        self.and :event_start_date, v
      when 's_title'
        self.and_keywords v, :title
      end
    end if params.size != 0

    return self
  end
end