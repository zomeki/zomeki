# encoding: utf-8
class PortalCalendar::Event < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
	belongs_to :event_genre, :class_name => 'PortalCalendar::Genre', :foreign_key => :event_genre_id
	belongs_to :event_status, :class_name => 'PortalCalendar::Status', :foreign_key => :event_status_id
	#XML出力用にassociationしておく。:event_statusだと<event_statu>となるため。
	belongs_to :event_statuses, :class_name => 'PortalCalendar::Status', :foreign_key => :event_status_id

	validates :title,	:presence => true
	validates :state, :presence => true
	validates :event_start_date, :presence => true
	validates :event_end_date, :presence => true
	validate :period_check?
	
private
	def period_check?
		if (! event_end_date.blank?) && (! event_start_date.blank?)
			errors.add(:event_end_date, 'は開始日以降を設定してください。') unless event_end_date >= event_start_date
		end
	end
	
public
	
  #イベント開催日の日付の配列を返す
  def get_event_dates
    dates = []
    (event_start_date .. event_end_date).each do |date|
      dates << date
    end
    return dates
  end
  
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

	#ジャンルの設定値は有効か？（未設定ではないか？）
	def genre_exists?
		begin
			self.event_genre.title
		rescue
			return false
		end
		return true
	end

	#ステイタスの設定値は有効か？（未設定ではないか？）
	def status_exists?
		begin
			self.event_status.title
		rescue
			return false
		end
		return true
	end

	#ジャンルもステイタスも設定値は有効か？（両方未設定ではないか？）
	def attr_exists?
		return genre_exists? && status_exists?
	end
	
	#ジャンルのタイトルを取得する
	def get_genre_title(bEmptyIfMisettei=false)
		begin
			self.event_genre.title
		rescue
			#未設定の場合には空白、もしくは「未設定」を返す
			bEmptyIfMisettei ? '' : self.locale(:invalid)
		end
	end
	
	#ステイタスのタイトルを取得する
	def get_status_title(bEmptyIfMisettei=false)
		begin
			self.event_status.title
		rescue
			#未設定の場合には空白、もしくは「未設定」を返す
			bEmptyIfMisettei ? '' : self.locale(:invalid)
		end
	end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_event_date'
        self.and :event_start_date, "<=", v
        self.and :event_end_date, ">=", v
      when 's_title'
        self.and_keywords v, :title
      end
    end if params.size != 0

    return self
  end
end
