class PortalGroup::Script::ThreadBusinessesController < Cms::Controller::Script::Publication
  def publish
    info_log 'PortalGroup::Script::ThreadBusinessesController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
