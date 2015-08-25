class PublicBbs::Script::ThreadsController < Cms::Controller::Script::Publication
  def publish
    info_log 'PublicBbs::Script::ThreadsController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
