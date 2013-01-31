# encoding: utf-8
class PortalCalendar::Public::Piece::EventLinksController < Sys::Controller::Public::Base
	def index

    @content  = PortalCalendar::Content::Base.find(Page.current_piece.content_id)
    @node     = @content.event_node
    @node_uri = @node.public_uri if @node
		return render(:text => '') unless @node
    
    @today    = Date.today
		@events_list = get_events(@content.id, @today, 1)
	end

private

	#指定日からndays間のイベントを取得する
	def get_events(content_id, basedate, ndays)
		sdate = basedate
		edate = basedate + ndays

		events = []
		(sdate .. edate).each do |day|
			# TODO: DBから一回で取ってスクリプトで日ごとに分解する方が早いかも。DBの負荷が高くないならこちらの方がすっきりしている。
			events << PortalCalendar::Event.get_period_records_with_content_id(content_id, day, day)
		end
		return events
	end

end
