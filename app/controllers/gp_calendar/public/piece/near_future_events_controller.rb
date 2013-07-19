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
  end
end
