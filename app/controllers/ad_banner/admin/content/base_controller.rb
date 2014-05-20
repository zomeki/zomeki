# encoding: utf-8
class AdBanner::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    AdBanner::Content::Banner
  end
end
