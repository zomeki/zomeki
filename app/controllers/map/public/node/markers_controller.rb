# encoding: utf-8

require 'will_paginate/array'

class Map::Public::Node::MarkersController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = Map::Content::Marker.find_by_id(@node.content.id)
    return http_error(404) unless @content

    @categories = []
  end

  def index
    if params[:c].present?
      markers = public_doc_markers
    else
      markers = @content.public_markers + public_doc_markers
    end
    @markers = markers.paginate(page: params[:page], per_page: 30)
  end

  private

  def public_doc_markers
    markers = []

    doc_contents = Cms::ContentSetting.where(name: 'map_content_marker_id', value: @content.id).map(&:content)
    doc_contents.select! {|dc| dc.model == 'GpArticle::Doc' && dc.site == Page.site }
    return markers if doc_contents.empty?

    doc_contents.each do |dc|
      GpArticle::Content::Doc.find(dc.id).public_docs.each do |d|
        if d.maps.empty? || d.maps.first.markers.empty?
          next
        else
          @categories |= d.categories.select {|c| c.public? }
        end

        next if params[:c].present? && !d.category_ids.include?(params[:c].to_i)

        d.maps.first.markers.each do |m|
          markers << @content.markers.build(title: d.title, latitude: m.lat, longitude: m.lng,
                                            window_text: %Q(<p>#{m.name}</p><p><a href="#{d.public_uri}">詳細</a></p>),
                                            doc: d)
        end
      end
    end

    return markers
  end
end
