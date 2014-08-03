# encoding: utf-8

require 'will_paginate/array'

class Map::Public::Node::MarkersController < Cms::Controller::Public::Base
  skip_filter :render_public_layout, :only => [:file_content]

  def pre_dispatch
    @node = Page.current_node
    @content = Map::Content::Marker.find_by_id(@node.content.id)
    return http_error(404) unless @content

    category = params[:category] ? params[:category] : params[:escaped_category].to_s.gsub('@', '/')
    @specified_category = find_category_by_specified_path(category)
  end

  def index
    markers = if @specified_category
                categorizations = GpCategory::Categorization.arel_table
                @content.public_markers.joins(:categorizations)
                                       .where(categorizations[:category_id].in(@specified_category.public_descendants.map(&:id)))
              else
                @content.public_markers
              end

    @all_markers = @content.sort_markers(markers.to_a.concat(doc_markers))

    @markers = @all_markers.paginate(page: params[:page], per_page: 30)

    return http_error(404) if @markers.current_page > @markers.total_pages
  end

  def file_content
    @marker = @content.markers.find_by_name(params[:name])
    return http_error(404) if @marker.nil? || @marker.files.empty?

    file = @marker.files.first
    mt = file.mime_type.presence || Rack::Mime.mime_type(File.extname(file.name))
    type, disposition = (mt =~ %r!^image/|^application/pdf$! ? [mt, 'inline'] : [mt, 'attachment'])
    disposition = 'attachment' if request.env['HTTP_USER_AGENT'] =~ /Android/
    send_file file.upload_path, :type => type, :filename => file.name, :disposition => disposition
  end

  private

  def doc_markers
    markers = []

    contents = GpArticle::Content::Doc.arel_table
    content_settings = Cms::ContentSetting.arel_table

    doc_contents = GpArticle::Content::Doc.joins(:settings)
                                          .where(contents[:site_id].eq(Page.site.id)
                                                 .and(content_settings[:name].eq('map_relation')
                                                 .and(content_settings[:value].eq('enabled'))))
                                          .select {|d| d.setting_extra_value(:map_relation, :map_content_id) == @content.id }

    return markers if doc_contents.empty?

    doc_contents.each do |dc|
      dc.public_docs.where(marker_state: 'visible').includes(:maps).each do |d|
        next if d.maps.empty? || d.maps.first.markers.empty?
        next if @specified_category && (d.marker_category_ids & @specified_category.public_descendants.map(&:id)).empty?

        d.maps.first.markers.each do |m|
          marker = Map::Marker.new(title: d.title, latitude: m.lat, longitude: m.lng,
                                   window_text: %Q(<p>#{m.name}</p><p><a href="#{d.public_uri}">詳細</a></p>),
                                   doc: d, created_at: d.display_published_at, updated_at: d.display_published_at)
          marker.categories = d.marker_categories
          marker.files = d.files
          marker.icon_category = d.marker_icon_category
          markers << marker
        end
      end
    end

    return markers
  end

  def find_category_by_specified_path(path)
    return nil unless path.kind_of?(String)
    category_type_name, category_path = path.split('/', 2)
    category_type = @content.category_types.find_by_name(category_type_name)
    return nil unless category_type
    category_type.find_category_by_path_from_root_category(category_path)
  end
end
