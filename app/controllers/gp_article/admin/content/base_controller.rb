# encoding: utf-8
class GpArticle::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    GpArticle::Content::Doc
  end
end
