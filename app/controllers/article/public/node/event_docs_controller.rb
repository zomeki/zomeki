# encoding: utf-8
class Article::Public::Node::EventDocsController < Cms::Controller::Public::Base
  include Article::Controller::Feed
  
  def month
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
    
    ## docs
    @items = []
    prev   = nil
    item = Article::Doc.new.public
    item.agent_filter(request.mobile)
    item.and :content_id, Page.current_node.content.id
    item.event_date_is(:year => @calendar.year, :month => @calendar.month)
    docs = item.find(:all, :order => 'event_date')
    return true if render_feed(docs)
      
    docs.each do |doc|
      key  = doc.event_date.strftime('%m%d')
      next unless day = @days[key]
      date   = nil
      anchor = nil
      if prev != key
        date   = request.mobile? ?
          "#{day[:month]}月#{day[:day]}日(#{day[:wday_label]})" :
          "#{day[:month]}月#{day[:day]}日（#{day[:wday_label]}）"
      end
      attr = doc.attribute_items[0]
      @items << {
        :date       => date,
        :date_id    => "day" + sprintf('%02d', day[:day]),
        :date_class => day[:class],
        :attr_class => attr ? "attribute attribute#{attr.name.camelize}" : nil,
        :attr_title => attr ? attr.title : nil,
        :doc        => doc
      }
      prev = key
    end
  end
end
