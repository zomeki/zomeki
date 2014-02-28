class SnsShare::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    SnsShare::Content::Account
  end
end
