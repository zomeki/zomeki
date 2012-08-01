# encoding: utf-8
class Calendar::Public::Node::EventsController < Cms::Controller::Public::Base
  def pre_dispatch
    @node     = Page.current_node
    @node_uri = @node.public_uri
    return http_error(404) unless @content = @node.content
    
    @today    = Date.today
    @min_date = Date.new(@today.year, @today.month, 1) << 0
    @max_date = Date.new(@today.year, @today.month, 1) >> 11
  end
  
  def index
    params[:year]  = @today.strftime("%Y").to_s
    params[:month] = @today.strftime("%m").to_s
    return index_monthly
  end
  
  def index_monthly
    return http_error(404) unless validate_date
    return http_error(404) if Date.new(@year, @month, 1) < @min_date
    return http_error(404) if Date.new(@year, @month, 1) > @max_date
    
    @sdate = "#{@year}-#{@month}-01"
    @edate = (Date.new(@year, @month, 1) >> 1).strftime('%Y-%m-%d')
    
    @calendar = Util::Date::Calendar.new(@year, @month)
    @calendar.month_uri = "#{@node_uri}:year/:month/"
    
    @items = {}
    @calendar.days.each{|d| @items[d[:date]] = [] if d[:month].to_i == @month }
    
    item = Calendar::Event.new.public
    item.and :content_id, @content.id
    item.and :event_date, ">=", @sdate.to_s
    item.and :event_date, "<", @edate.to_s
    item.and :event_date, "IS NOT", nil
    events = item.find(:all, :order => 'event_date ASC, id ASC')
    
    (events + event_docs).each do |ev|
      @items[ev.event_date.to_s] << ev
    end
    
    @pagination = Util::Html::SimplePagination.new
    @pagination.prev_label = "前の月"
    @pagination.next_label = "次の月"
    @pagination.prev_uri   = @calendar.prev_month_uri if @calendar.prev_month_date >= @min_date
    @pagination.next_uri   = @calendar.next_month_uri if @calendar.next_month_date <= @max_date
    
    render :action => "index_monthly"
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
    
    item = Calendar::Event.new.public
    item.and :content_id, @content.id
    item.and :event_date, ">=", @sdate.to_s
    item.and :event_date, "<", @edate.to_s
    item.and :event_date, "IS NOT", nil
    events = item.find(:all, :order => 'event_date ASC, id ASC')
    
    (events + event_docs).each do |ev|
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
  end
  
protected
  def event_docs
    content_id = @content.setting_value(:doc_content_id)
    return [] if content_id.blank?
    
    item = Cms::Content.new
    item.and :id, content_id
    item.and :site_id, Page.site.id
    return [] unless @doc_content = item.find(:first)
    
    case @doc_content.model
    when 'Article::Doc'
      doc = Article::Doc.new.public
      doc.agent_filter(request.mobile)
      doc.and :content_id, content_id
      doc.event_date_is(:year => @year, :month => @month)
      doc.find(:all, :order => 'event_date')
    when 'PortalArticle::Doc'
      doc = PortalArticle::Doc.new.public
      doc.agent_filter(request.mobile)
      doc.and :content_id, content_id
      doc.event_date_is(:year => @year, :month => @month)
      doc.find(:all, :order => 'event_date')
    when 'PortalGroup::Group'
      @doc_content_type = :portal
      doc = PortalArticle::Doc.new.public
      doc.agent_filter(request.mobile)
      doc.and :portal_group_id, content_id
      doc.event_date_is(:year => @year, :month => @month)
      doc.find(:all, :order => 'event_date')
    else
      []
    end
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