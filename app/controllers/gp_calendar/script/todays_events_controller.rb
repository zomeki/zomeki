class GpCalendar::Script::TodaysEventsController < Cms::Controller::Script::Publication
  def publish
    info_log 'GpCalendar::Script::TodaysEventsController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
