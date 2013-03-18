# encoding: utf-8
class PortalArticle::Public::Piece::ArchivesController < Sys::Controller::Public::Base
  include PortalArticle::Controller::Feed

	def last_date_of_the_month(year, month)
		dt = Date.new(year, month, 1)
		return (dt >> 1) - 1
	end
	
	def last_day_of_the_month(year, month)
		dt = last_date_of_the_month(year, month)
		return dt.day
	end
	
	def last_date_of_this_month
		dt = Date.today
		return last_date_of_the_month(dt.year, dt.month)
	end
	
  def index
    @piece   = Page.current_piece
    @content = PortalArticle::Content::Doc.find(@piece.content_id)
    @node = @content.recent_node
    
    limit = Page.current_piece.setting_value(:list_count)
    limit = (limit.to_s =~ /^[1-9][0-9]*$/) ? limit.to_i : 10

		#この１年間
		edate = last_date_of_this_month()
		sdate = (edate << 12) + 1
		@lists = get_count(edate, sdate, @piece.content_id)
		@base_uri = Page.current_node.public_uri
  end
end
