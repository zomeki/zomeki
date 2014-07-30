class Gnav::Script::MenuItemsController < Cms::Controller::Script::Publication
  def publish
    info_log 'Gnav::Script::MenuItemsController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
