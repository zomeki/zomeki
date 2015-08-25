class AdBanner::Script::BannersController < Cms::Controller::Script::Publication
  def publish
    render text: 'OK'
  end
end
