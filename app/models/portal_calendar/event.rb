# encoding: utf-8
class PortalCalendar::Event < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  belongs_to :status,         :foreign_key => :state,             :class_name => 'Sys::Base::Status'
	belongs_to :genre, :class_name => 'PortalCalendar::Genre', :foreign_key => :genre_id
	belongs_to :event_status, :class_name => 'PortalCalendar::Status', :foreign_key => :status_id
	
  validates_presence_of :state, :event_date, :title
  
	def get_genre_title
		self.genre.title
	end
	
	def get_status_title
		self.event_status.title
	end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_event_date'
        self.and :event_date, v
      when 's_title'
        self.and_keywords v, :title
      end
    end if params.size != 0

    return self
  end
end