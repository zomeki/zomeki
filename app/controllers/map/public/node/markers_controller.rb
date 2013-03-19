# encoding: utf-8
class Map::Public::Node::MarkersController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = Map::Content::Marker.find_by_id(@node.content.id)
    return http_error(404) unless @content
  end

  def index
    @markers = @content.public_markers + public_doc_markers
  end

  private

  def public_doc_markers
    markers = []

    doc_contents = Cms::ContentSetting.where(name: 'map_content_marker_id', value: @content.id).map(&:content)
    doc_contents.reject! {|dc| dc.model != 'GpArticle::Doc' || dc.site != Page.site }
    return markers if doc_contents.empty?

    doc_contents.each do |dc|
      GpArticle::Content::Doc.find(dc.id).public_docs.each do |d|
        next if d.maps.empty?
        d.maps.first.markers.each do |m|
          markers << @content.markers.build(title: m.name, latitude: m.lat, longitude: m.lng,
                                            window_text: %Q(<a href="#{d.public_uri}">#{d.title}</a>))
        end
      end
    end

    return markers
  end
end
