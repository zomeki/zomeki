# encoding: utf-8
#class PortalCalendar::Public::Node::EventsController < Cms::Controller::Public::Base
class PortalCalendar::Public::Node::EventsController < PortalCalendar::Public::Node::BaseController
  def index
    params[:year]  = @today.strftime("%Y").to_s
    params[:month] = @today.strftime("%m").to_s

		return calendar_monthly
	end
	
	def calendar_monthly
    return http_error(404) unless validate_date
    return http_error(404) if Date.new(@year, @month, 1) < @min_date
    return http_error(404) if Date.new(@year, @month, 1) > @max_date

		@events, @items = prepare_monthly_data

		#カレンダーの開始曜日
		@start_wday = 0
		first_date = Date.new(@year, @month, 1)
		#カレンダー先頭の日(カレンダーの先頭日はだいたい前の月なのでその調整）
		box_start_date = first_date - first_date.cwday  + @start_wday
		if box_start_date > first_date
			box_start_date = box_start_date - 7
		end
 		max_row = @max_row
		max_column = @max_column
		base_nbr = @base_nbr
		
		#表示のイメージのまま、その日のデータを詰めていく
		@box=[]
		base_nbr.upto(max_row) do |row|
			@box[row]=[]
			base_nbr.upto(max_column) do |coloumn|
				data = {:date => box_start_date + row*(max_column+1) + coloumn}
				#hashキーのフォーマットは yyyy-mm-dd
				data.merge!({:events => @items[data[:date].strftime('%Y-%m-%d')]})
				@box[row][coloumn] = data
			end
		end

		respond_to do |format|
			format.xml {render :xml => to_xml(@events)}
			format.html {render :action => "index_calendar"}
		end
	end
end