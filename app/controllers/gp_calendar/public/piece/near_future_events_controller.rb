# encoding: utf-8
class GpCalendar::Public::Piece::NearFutureEventsController < GpCalendar::Public::Piece::BaseController
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
end
