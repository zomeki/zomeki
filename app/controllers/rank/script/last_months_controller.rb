class Rank::Script::LastMonthsController < Cms::Controller::Script::Publication
  def publish
    info_log 'Rank::Script::LastMonthsController#publish'
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end
