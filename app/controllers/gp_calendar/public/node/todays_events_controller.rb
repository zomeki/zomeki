# encoding: utf-8
class GpCalendar::Public::Node::TodaysEventsController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = GpCalendar::Content::Event.find_by_id(@node.content.id)
    return http_error(404) unless @content
  end

  def index
    @today = Date.today
    criteria = {date: @today}
    @events = GpCalendar::Event.public.all_with_content_and_criteria(@content, criteria)

    merge_docs_into_events(event_docs(@today, @today), @events)

    if (category = find_category_by_specified_path(params[:category]))
      @events.select! {|e| e.category_ids.include?(category.id) }
    end
  end

  private

  def find_category_by_specified_path(path)
    return nil unless path.kind_of?(String)
    category_type_name, category_path = path.split('/', 2)
    category_type = @content.category_types.find_by_name(category_type_name)
    return nil unless category_type
    category_type.find_category_by_path_from_root_category(category_path)
  end

  def event_docs(start_date, end_date)
    doc_contents = Cms::ContentSetting.where(name: 'gp_calendar_content_event_id', value: @content.id).map(&:content)
    doc_contents.select! {|dc| dc.site == Page.site }
    return [] if doc_contents.empty?

    doc_contents.map {|dc|
      case dc.model
      when 'GpArticle::Doc'
        dc = GpArticle::Content::Doc.find(dc.id)
        docs = dc.public_docs.table
        dc.public_docs.where(event_state: 'visible').where(docs[:event_date].gteq(start_date).and(docs[:event_date].lteq(end_date)))
      else
        []
      end
    }.flatten
  end

  def merge_docs_into_events(docs, events)
    docs.each do |doc|
      event = GpCalendar::Event.new(title: doc.title, href: doc.public_uri, target: '_self',
                                    started_on: doc.event_date, ended_on: doc.event_date, description: doc.summary)
      event.files = doc.files
      events << event
    end
    events.sort! {|a, b| a.started_on <=> b.started_on }
  end
end
