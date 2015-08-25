module Cms::ApiCommon
  extend ActiveSupport::Concern

  included do
  end

  def render_404
    render json: {reason: 'Not Found'}, status: 404
  end

  def render_405
    render json: {reason: 'Method Not Allowed'}, status: 405
  end
end
