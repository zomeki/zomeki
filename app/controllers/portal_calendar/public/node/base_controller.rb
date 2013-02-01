# encoding: utf-8
class PortalCalendar::Public::Node::BaseController < Cms::Controller::Public::Base
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
		
		#パラメータのセットがない
		@nil_param = params[:egnr].nil? ? (params[:estt].nil? ? true : false) : false

		#パラメータのセットもなくGETで開いたときはページを初期状態で開く
		@init_page = (/GET/ =~ request.headers['REQUEST_METHOD']) && @nil_param
  end

	#要素を整数化した配列を返す
	def conv_to_i(h)
		h.map{|item| item.to_i}
	end
	
	def prepare_monthly_data
    return http_error(404) unless validate_date
    return http_error(404) if Date.new(@year, @month, 1) < @min_date
    return http_error(404) if Date.new(@year, @month, 1) > @max_date
		
		if @init_page
			@genre_keys = @genres.map{|item| item.id}
			@status_keys = @statuses.map{|item| item.id}
		else
			#前後の月の抽出条件を引き継ぐ egnr=event genres, estt=event statuses
			_genres = params[:egnr].nil? ? [] : params[:egnr].split(",")
			_statuses = params[:estt].nil? ? [] : params[:estt].split(",")
		
			#フォームでsubmitされたときはフォームの抽出条件で処理する
			@genre_keys = params[:genre].nil? ? conv_to_i(_genres) : conv_to_i(params[:genre].keys)
			@status_keys = params[:status].nil? ? conv_to_i(_statuses) : conv_to_i(params[:status].keys)
		end
    
    @sdate = "#{@year}-#{@month}-01"
    @edate = (Date.new(@year, @month, 1) >> 1).strftime('%Y-%m-%d')
    
    @calendar = Util::Date::Calendar.new(@year, @month)
    @calendar.month_uri = "#{@node_uri}:year/:month/index"
    
    @items = {}
    @calendar.days.each{|d| @items[d[:date]] = [] if d[:month].to_i == @month }

		@events = PortalCalendar::Event.get_period_records_with_content_id(@content.id, @sdate, @edate)
		@events = @events.where("genre_id IN (?) AND status_id IN (?)", @genre_keys, @status_keys)
		
		@events.each do |ev|
      (ev.event_start_date .. ev.event_end_date).each do |evdate|
				#その月のイベントか？
				# TODO: 要確認/元の資料のとおりの実装だが、これだとカレンダーに表示される前後の月の範囲のイベントを表示しない仕様。前後の月に移動するとイベントを表示するので違和感あり？
				next if evdate.month != @month

				@items[evdate.to_s] << ev
			end
    end

		condition_str = "egnr=#{@genre_keys.join(",")}&estt=#{@status_keys.join(",")}"
		
    @pagination = Util::Html::SimplePagination.new
    @pagination.prev_label = "&lt;前の月"
    @pagination.next_label = "次の月&gt;"
    @pagination.prev_uri   = @calendar.prev_month_uri + "?#{condition_str}" if @calendar.prev_month_date >= @min_date
    @pagination.next_uri   = @calendar.next_month_uri + "?#{condition_str}" if @calendar.next_month_date <= @max_date
	end

protected
  def validate_date
    @month = params[:month]
    @year  = params[:year]
    return false if !@month.blank? && @month !~ /^(0[1-9]|10|11|12)$/
    return false if !@year.blank? && @year !~ /^[1-9][0-9][0-9][0-9]$/
    @year  = @year.to_i
    @month = @month.to_i if @month
    return true
  end
end