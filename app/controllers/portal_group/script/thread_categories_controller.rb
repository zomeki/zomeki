class PortalGroup::Script::ThreadCategoriesController < Cms::Controller::Script::Publication
  def publish
    info_log 'PortalGroup::Script::ThreadCategoriesController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
