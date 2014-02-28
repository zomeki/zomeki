# encoding: utf-8
class Tag::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    Tag::Content::Tag
  end
end
