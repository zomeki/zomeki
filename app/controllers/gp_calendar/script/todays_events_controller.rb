class GpCalendar::Script::TodaysEventsController < GpCalendar::Script::BaseController
  def publish
    publish_without_months
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
