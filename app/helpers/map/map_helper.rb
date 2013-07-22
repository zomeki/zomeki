# encoding: utf-8
module Map::MapHelper
  def default_lat_lng
    if @content.latitude.blank? && @content.longitude.blank?
      if @markers.empty?
        [0, 0]
      else
        [@markers.first.latitude, @markers.first.longitude]
      end
    else
      [@content.latitude, @content.longitude]
    end
  end

  def default_latitude
    default_lat_lng.first
  end

  def default_longitude
    default_lat_lng.last
  end
end
