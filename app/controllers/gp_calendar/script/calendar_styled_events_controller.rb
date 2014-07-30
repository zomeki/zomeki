class GpCalendar::Script::CalendarStyledEventsController < Cms::Controller::Script::Publication
  def publish
    info_log 'GpCalendar::Script::CalendarStyledEventsController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
