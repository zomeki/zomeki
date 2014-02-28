# encoding: utf-8
class Map::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    Map::Content::Marker
  end
end
