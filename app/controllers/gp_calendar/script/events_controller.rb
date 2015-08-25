class GpCalendar::Script::EventsController < GpCalendar::Script::BaseController
  def publish
    publish_with_months
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
