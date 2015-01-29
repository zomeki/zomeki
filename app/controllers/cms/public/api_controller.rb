class Cms::Public::ApiController < Cms::Controller::Public::Base
  skip_filter :render_public_layout

  def receive
    render text: params.inspect
  end
end
