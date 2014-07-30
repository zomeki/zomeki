class PublicBbs::Script::RecentThreadsController < Cms::Controller::Script::Publication
  def publish
    info_log 'PublicBbs::Script::RecentThreadsController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
