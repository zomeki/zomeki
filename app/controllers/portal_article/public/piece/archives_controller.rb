# encoding: utf-8
class PortalArticle::Public::Piece::ArchivesController < Sys::Controller::Public::Base
  include PortalArticle::Controller::Feed
	#12ヶ月分表示する
	@@term = 12
	
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

		#設定に設定した表示月数(未選択の時は@@termsを設定）
		term = @content.setting_value(:archive_show_terms).to_i
		term = @@term if term == 0
		
		edate = last_date_of_this_month()
		sdate = (edate << term) + 1
		@lists = get_count(edate, sdate, @piece.content_id)
		@base_uri = Page.current_node.public_uri
  end
end
