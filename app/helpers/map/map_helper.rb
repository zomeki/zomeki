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

  def marker_image(marker)
    unless (doc = marker.doc)
      file = marker.files.first
      return '' unless file.parent.content.public_node
      return image_tag("#{file.parent.content.public_node.public_uri}#{file.parent.name}/file_contents/#{url_encode file.name}")
    else
      return '' unless doc.content.public_node
    end

    image_file = doc.image_files.detect{|f| f.name == doc.list_image } || doc.image_files.first if doc.list_image.present?

    if image_file
      image_tag("#{doc.content.public_node.public_uri}#{doc.name}/file_contents/#{url_encode image_file.name}")
    else
      unless (img_tags = Nokogiri::HTML.parse(doc.body).css('img[src^="file_contents/"]')).empty?
        filename = File.basename(img_tags.first.attributes['src'].value)
        image_tag("#{doc.content.public_node.public_uri}#{doc.name}/file_contents/#{url_encode filename}")
      else
        ''
      end
    end
  end

  def title_replace(doc, doc_style)
    return unless doc

    contents = {
      title_link: content_tag(:span, link_to(doc.title, doc.public_uri), class: 'title_link'),
      title: content_tag(:span, doc.title, class: 'title'),
      subtitle: content_tag(:span, doc.subtitle, class: 'subtitle'),
      summary:  doc.summary,
      }

    if Page.mobile?
      contents[:title_link]
    else
      doc_style.gsub(/@\w+@/, {
        '@title_link@' => contents[:title_link],
        '@title@'    => contents[:title],
        '@subtitle@' => contents[:subtitle],
        '@summary@'  => contents[:summary],
      }).html_safe
    end
  end
end
