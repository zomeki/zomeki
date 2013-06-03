# encoding: utf-8
class Article::Public::Piece::CalendarsController < Sys::Controller::Public::Base
  def index
    if params[:year] && params[:month]
      @calendar = Util::Date::Calendar.new params[:year].to_i, params[:month].to_i
    else
      @calendar = Util::Date::Calendar.new
    end
    
    @content = Article::Content::Doc.find(Page.current_piece.content_id)
    @node = @content.event_node
    
    uri = @node ? @node.public_uri : '/'
    @calendar.year_uri  = "#{uri}:year/"
    @calendar.month_uri = "#{uri}:year/:month/"
    @calendar.day_uri   = "#{uri}:year/:month/#day:day"
    
    dates = []
    if @node
      doc = Article::Doc.new.public
      doc.agent_filter(request.mobile)
      doc.and :content_id, @content.id
      doc.event_date_is(:year => @calendar.year, :month => @calendar.month)
      docs = doc.find(:all, :select => 'event_date', :group => :event_date)
      docs.each{|doc| dates << doc.event_date}
    end
    
    @calendar.day_link = dates
  end
end
