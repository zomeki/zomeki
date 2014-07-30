class Tag::Script::TagsController < Cms::Controller::Script::Publication
  def publish
    info_log 'Tag::Script::TagsController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
