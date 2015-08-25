class PortalCalendar::Script::ListsController < Cms::Controller::Script::Publication
  def publish
    info_log 'PortalCalendar::Script::ListsController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
