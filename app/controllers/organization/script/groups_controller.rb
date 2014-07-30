class Organization::Script::GroupsController < Cms::Controller::Script::Publication
  def publish
    info_log 'Organization::Script::GroupsController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
