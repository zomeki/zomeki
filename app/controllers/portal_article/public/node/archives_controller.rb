# encoding: utf-8
class PortalArticle::Public::Node::ArchivesController < Cms::Controller::Public::Base
  include PortalArticle::Controller::Feed
	
	def index
    if params[:year] && params[:month]
      @calendar = Util::Date::Calendar.new params[:year].to_i, params[:month].to_i
    else
      @calendar = Util::Date::Calendar.new
    end
    return http_error(404) if @calendar.errors
   
    ## calendar
    base_uri = Page.current_node.public_uri
    @calendar.year_uri  = "#{base_uri}:year/"
    @calendar.month_uri = "#{base_uri}:year/:month/"
    @calendar.day_uri   = "#{base_uri}:year/:month/#day:day"
    
    @days = {}
    @calendar.days.each do |day|
      next if day[:class] =~ /Month/
      key = "#{sprintf('%02d', day[:month])}#{sprintf('%02d', day[:day])}"
      @days[key] = day
    end
    
    ## pagination
    now = Time.now
    min = "#{now.year - 1}#{format('%02d', now.month)}".to_i
    max = "#{now.year + 1}#{format('%02d', now.month)}".to_i
    cym = "#{@calendar.year}#{format('%02d', @calendar.month)}".to_i
    
    return http_error(404) if cym < min
    return http_error(404) if cym > max
    @prev_link = cym <= min ? false : true
    @next_link = cym >= max ? false : true
		
    @content = Page.current_node.content
    
    doc = PortalArticle::Doc.new.public
    doc.agent_filter(request.mobile)
    doc.and :content_id, @content.id

		sdate = Date.new(@calendar.year, @calendar.month, 1)
		edate = sdate >> 1
	
		doc.and :published_at, ">=", sdate
		doc.and :published_at, "<",  edate
		
    #doc.search params
    doc.page params[:page], (request.mobile? ? 20 : 50)
    @docs = doc.find(:all, :order => 'published_at DESC')
  
		Page.title = Page.title + sprintf(" %4d年%02d月", @calendar.year, @calendar.month)
		
		return true if render_feed(@docs)
    return http_error(404) if @docs.current_page > @docs.total_pages
	end
  
end
