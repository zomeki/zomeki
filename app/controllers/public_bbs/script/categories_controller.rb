class PublicBbs::Script::CategoriesController < Cms::Controller::Script::Publication
  def publish
    info_log 'PublicBbs::Script::CategoriesController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
