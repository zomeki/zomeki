class Survey::Script::FormsController < Cms::Controller::Script::Publication
  def publish
    info_log 'Survey::Script::FormsController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
