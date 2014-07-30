class PortalGroup::Script::ThreadAttributesController < Cms::Controller::Script::Publication
  def publish
    info_log 'PortalGroup::Script::ThreadAttributesController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
