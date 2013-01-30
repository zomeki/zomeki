# encoding: utf-8
class PortalCalendar::Public::Node::EventsController < Cms::Controller::Public::Base
  def pre_dispatch
    @node     = Page.current_node
    @node_uri = @node.public_uri
    return http_error(404) unless @content = @node.content
    
    @today    = Date.today
    @min_date = Date.new(@today.year, @today.month, 1) << 0
    @max_date = Date.new(@today.year, @today.month, 1) >> 11

		@genres = PortalCalendar::Event.get_genre_valid_list(@content.id)
		@statuses = PortalCalendar::Event.get_status_valid_list(@content.id)

		@max_row = 5
		@max_column = 7 - 1
		@base_nbr = 0
		
  end

	def conv_to_i(h)
		h.map{|item| item.to_i}
	end
	
	def calendar
    params[:year]  = @today.strftime("%Y").to_s
    params[:month] = @today.strftime("%m").to_s

		return calendar_monthly
	end
	
	def prepare_monthly_data(uri_suffix="")
    return http_error(404) unless validate_date
    return http_error(404) if Date.new(@year, @month, 1) < @min_date
    return http_error(404) if Date.new(@year, @month, 1) > @max_date

		@genre_keys = params[:genre].nil? ? [] : conv_to_i(params[:genre].keys)
		@status_keys = params[:status].nil? ? [] : conv_to_i(params[:status].keys)
    
    @sdate = "#{@year}-#{@month}-01"
    @edate = (Date.new(@year, @month, 1) >> 1).strftime('%Y-%m-%d')
    
    @calendar = Util::Date::Calendar.new(@year, @month)
    @calendar.month_uri = "#{@node_uri}:year/:month/" + uri_suffix
    
    @items = {}
    @calendar.days.each{|d| @items[d[:date]] = [] if d[:month].to_i == @month }

		events = PortalCalendar::Event.get_period_records_with_content_id(@content.id, @sdate, @edate)
		events = events.where("genre_id IN (?) AND status_id IN (?)", @genre_keys, @status_keys)
		
		events.each do |ev|
      (ev.event_start_date .. ev.event_end_date).each do |evdate|
				#その月のイベントか？
				next if evdate.month != @month

				@items[evdate.to_s] << ev
			end
    end
    
    @pagination = Util::Html::SimplePagination.new
    @pagination.prev_label = "&lt;前の月"
    @pagination.next_label = "次の月&gt;"
    @pagination.prev_uri   = @calendar.prev_month_uri if @calendar.prev_month_date >= @min_date
    @pagination.next_uri   = @calendar.next_month_uri if @calendar.next_month_date <= @max_date
	end
	
	def calendar_monthly

		prepare_monthly_data("calendar")

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
			format.html {render :action => "index_calendar"}
		end

	end

  
  def index
    params[:year]  = @today.strftime("%Y").to_s
    params[:month] = @today.strftime("%m").to_s

    return index_monthly
  end
  
  def index_monthly

		prepare_monthly_data
		
		respond_to do |format|
			format.html {render :action => "index_monthly"}
		end
  end
  
  def index_yearly
    return http_error(404) unless validate_date
    return http_error(404) if @year < @min_date.year
    return http_error(404) if @year > @max_date.year
    
    @sdate = "#{@year}-01-01"
    @edate = (Date.new(@year, 1, 1) >> 12).strftime('%Y-%m-%d')
    
    @days  = []
    @items = {}
    @wdays = Util::Date::Calendar.wday_specs
    
    item = PortalCalendar::Event.new.public
    item.and :content_id, @content.id
    item.and :event_date, ">=", @sdate.to_s
    item.and :event_date, "<", @edate.to_s
    item.and :event_date, "IS NOT", nil
    events = item.find(:all, :order => 'event_date ASC, id ASC')
    
    events.each do |ev|
      unless @items.key?(ev.event_date.to_s)
        date = ev.event_date
        wday = @wdays[date.strftime("%w").to_i]
        day  = {
          :date_object => date,
          :date        => date.to_s,
          :class       => "day #{wday[:class]}",
          :wday_label  => wday[:label],
          :holiday     => Util::Date::Holiday.holiday?(date.year, date.month, date.day) || nil
        }
        day[:class] += " holiday" if day[:holiday]
        @days << day
        @items[ev.event_date.to_s] = []
      end
      @items[ev.event_date.to_s] << ev
    end
    
    @pagination = Util::Html::SimplePagination.new
    @pagination.prev_label = "&lt;前の年"
    @pagination.next_label = "次の年&gt;"
    @pagination.prev_uri   = "#{@node_uri}#{@year - 1}/" if (@year - 1) >= @min_date.year
    @pagination.next_uri   = "#{@node_uri}#{@year + 1}/" if (@year + 1) <= @max_date.year
  
		render :action => "index_yearly"
 	end
  
protected
  def event_docs
    content_id = @content.setting_value(:doc_content_id)
    return [] if content_id.blank?
    
    doc = Article::Doc.new.public
    doc.agent_filter(request.mobile)
    doc.and :content_id, content_id
    doc.event_date_is(:year => @year, :month => @month)
    doc.find(:all, :order => 'event_date')
  end
  
  def validate_date
    @month = params[:month]
    @year  = params[:year]
    return false if !@month.blank? && @month !~ /^(0[1-9]|10|11|12)$/
    return false if !@year.blank? && @year !~ /^[1-9][0-9][0-9][0-9]$/
    @year  = @year.to_i
    @month = @month.to_i if @month
    params[:calendar_event_year]  = @year
    params[:calendar_event_month] = @month
    params[:calendar_event_min_date] = @min_date
    params[:calendar_event_max_date] = @max_date
    return true
  end
end