# encoding: utf-8
class GpCalendar::Public::Piece::NearFutureEventsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCalendar::Piece::NearFutureEvent.find_by_id(Page.current_piece.id)
    return render(:text => '') unless @piece

    @item = Page.current_item
  end

  def index
    today = Date.today
    @todays_events = GpCalendar::Event.public.all_with_content_and_criteria(@piece.content, date: today)
    @tomorrows_events = GpCalendar::Event.public.all_with_content_and_criteria(@piece.content, date: today.tomorrow)

    merge_docs_into_events(event_docs(today, today), @todays_events)
    merge_docs_into_events(event_docs(today.tomorrow, today.tomorrow), @tomorrows_events)
  end

  private

  def event_docs(start_date, end_date)
    doc_contents = Cms::ContentSetting.where(name: 'gp_calendar_content_event_id', value: @piece.content.id).map(&:content)
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
