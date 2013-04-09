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
    @node = @content.archive_node
		
    limit = Page.current_piece.setting_value(:list_count)
    limit = (limit.to_s =~ /^[1-9][0-9]*$/) ? limit.to_i : 10

		#記事設定/表示月数(未選択の時は0で無制限）
		term = @content.setting_value(:archive_show_terms).to_i

		#記事設定/記事数ゼロの時、表示するかどうか
		show_count_zero = @content.setting_value(:archive_show_count_zero).to_i == 1 ? true : false
		
		edate = last_date_of_this_month()
		if term == 0
			#全範囲
			doc = PortalArticle::Doc.find(:first, :conditions=>["content_id=?", @piece.content_id], :order=>"published_at ASC")
			if doc.nil?
				sdate = Date.new(edate.year, edate.month, 1)
			else	
				sdate = doc.published_at
				sdate = Date.new(sdate.year, sdate.month, 1)
			end
		else
			sdate = (edate << term) + 1
		end
		
		@lists = get_count(edate, sdate, @piece.content_id, show_count_zero)
		@base_uri = @node.public_uri
  end
end
