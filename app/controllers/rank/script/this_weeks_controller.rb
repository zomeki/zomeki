class Rank::Script::ThisWeeksController < Cms::Controller::Script::Publication
  def publish
    info_log 'Rank::Script::ThisWeeksController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
