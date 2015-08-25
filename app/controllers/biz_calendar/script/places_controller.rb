class BizCalendar::Script::PlacesController < Cms::Controller::Script::Publication
  def publish
    info_log 'BizCalendar::Script::PlacesController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
