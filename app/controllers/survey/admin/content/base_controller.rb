# encoding: utf-8
class Survey::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    Survey::Content::Form
  end
end
