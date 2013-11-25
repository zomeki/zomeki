# encoding: utf-8
module GpCalendar::GpCalendarHelper
  def localize_wday(style, wday)
    style.gsub('%A', t('date.day_names')[wday]).gsub('%a', t('date.abbr_day_names')[wday])
  end

  def nodes_for_category_types(nodes)
    nodes.select {|n| %w!GpCalendar::Event
                         GpCalendar::CalendarStyledEvent!.include?(n.model) }
  end

  def nodes_for_daily_links(nodes)
    nodes_for_category_types(nodes)
  end

  def nodes_for_monthly_links(nodes)
    nodes_for_category_types(nodes)
  end

  def event_images(event, count: 0)
    unless (doc = event.doc)
      count = (count > 0 ? count : event.files.size)
      return event.files[0...count].map{|f|
        image_tag("#{f.parent.content.public_node.public_uri}#{f.parent.name}/file_contents/#{url_encode f.name}")
      }.join.html_safe
    end

    srcs = []
    if doc.list_image.present?
      file = doc.image_files.detect{|f| f.name == doc.list_image } || doc.image_files.first
      srcs << image_tag("#{doc.content.public_node.public_uri}#{doc.name}/file_contents/#{url_encode file.name}")
    end
    Nokogiri::HTML.parse(doc.body).css('img[src^="file_contents/"]').each do |img|
      break if count > 0 && srcs.size >= count
      filename = File.basename(img.attributes['src'].value)
      srcs << image_tag("#{doc.content.public_node.public_uri}#{doc.name}/file_contents/#{url_encode filename}")
    end
    srcs.join.html_safe
  end
end
