class PublicBbs::Script::TagThreadsController < Cms::Controller::Script::Publication
  def publish
    info_log 'PublicBbs::Script::TagThreadsController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
