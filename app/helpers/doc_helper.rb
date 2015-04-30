# encoding: utf-8
module DocHelper
  def doc_replace(doc, doc_style, date_style, time_style='')

    link_to_options = link_to_doc_options(doc)

    title_link = if link_to_options
                   link_to *([doc.title] + link_to_options)
                 else
                   h doc.title
                 end

    image_file = doc.image_files.detect{|f| f.name == doc.list_image } || doc.image_files.first if doc.list_image.present?

    doc_image = if image_file
                  image_tag("#{doc.public_uri(without_filename: true)}file_contents/#{url_encode image_file.name}")
                else
                  unless (img_tags = Nokogiri::HTML.parse(doc.body).css('img[src^="file_contents/"]')).empty?
                    filename = File.basename(img_tags.first.attributes['src'].value)
                    image_tag("#{doc.public_uri(without_filename: true)}file_contents/#{url_encode filename}")
                  else
                    ''
                  end
                end

    doc_image_link = if link_to_options && doc_image.present?
                       link_to *([doc_image] + link_to_options)
                     else
                       doc_image
                     end

    publish_date = if (dpa = doc.display_published_at)
                     ds = localize_wday(date_style, dpa.wday)
                     content_tag(:span, dpa.strftime(ds), class: 'publish_date')
                   else
                     ''
                   end
    update_date = if (dua = doc.display_updated_at)
                     ds = localize_wday(date_style, dua.wday)
                     content_tag(:span, dua.strftime(ds), class: 'update_date')
                   else
                     ''
                   end

    publish_time = if (dpa = doc.display_published_at)
                     content_tag(:span, dpa.strftime(time_style), class: 'publish_time')
                   else
                     ''
                   end
    update_time = if (dua = doc.display_updated_at)
                    content_tag(:span, dua.strftime(time_style), class: 'update_time')
                  else
                    ''
                  end

    contents = {
      title_link: title_link.blank? ? '' : content_tag(:span, title_link, class: 'title_link'),
      title: doc.title.blank? ? '' : content_tag(:span, doc.title, class: 'title'),
      subtitle: doc.subtitle.blank? ? '' : content_tag(:span, doc.subtitle, class: 'subtitle'),
      publish_date: publish_date,
      update_date: update_date,
      publish_time: publish_time,
      update_time: update_time,
      summary: doc.summary.blank? ? '' : content_tag(:span, doc.summary, class: 'summary'),
      group: doc.creator.blank? ? '' : content_tag(:span, doc.creator.group.name, class: 'group'),
      category_link: doc.categories.blank? ? '' : content_tag(:span, doc.categories.map{|c|
          content_tag(:span, link_to(c.title, c.public_uri),
                      class: "#{c.category_type.name}-#{c.ancestors.map(&:name).join('-')}")
        }.join.html_safe, class: 'category'),
      category: doc.categories.blank? ? '' : content_tag(:span, doc.categories.map{|c|
          content_tag(:span, c.title,
                    class: "#{c.category_type.name}-#{c.ancestors.map(&:name).join('-')}")
        }.join.html_safe, class: 'category'),
      image_link: doc_image_link.blank? ? '' : content_tag(:span, doc_image_link, class: 'image'),
      image: doc_image.blank? ? '' : content_tag(:span, doc_image, class: 'image'),
      body_beginning: doc.body.blank? ? '' : content_tag(:span, "#{file_path_expanded_body(doc)}#{content_tag(:div, link_to(doc.body_more_link_text, doc.public_uri), class: 'continues') if doc.body_more.present? }".html_safe, class: 'body'),
      body: "#{doc.body}#{doc.body_more}".blank? ? '' : content_tag(:span, "#{file_path_expanded_body(doc)}#{doc.body_more}".html_safe, class: 'body'),
      user: doc.creator.user.try(:name).blank? ? '' : content_tag(:span, doc.creator.user.name, class: 'user'),
      comment_count: content_tag(:span, link_to(doc.comments.count, "#{doc.public_uri}#comments"), class: 'comment_count'),
      }

    if Page.mobile?
      contents[:title_link]
    else
      doc_style = doc_style.gsub(/@doc{{@(.+)@}}doc@/m){|m| link_to($1.html_safe, doc.public_uri, class: 'doc_link') }
      doc_style = doc_style.gsub(/@body_(\d+)@/){|m| content_tag(:span, truncate(strip_tags(doc.body), length: $1.to_i).html_safe, class: 'body') }

      doc_style.gsub(/@\w+@/, {
        '@title_link@' => contents[:title_link],
        '@title@' => contents[:title],
        '@subtitle@' => contents[:subtitle],
        '@publish_date@' => contents[:publish_date],
        '@update_date@' => contents[:update_date],
        '@publish_time@' => contents[:publish_time],
        '@update_time@' => contents[:update_time],
        '@summary@' => contents[:summary],
        '@group@' => contents[:group],
        '@category_link@' => contents[:category_link],
        '@category@' => contents[:category],
        '@image_link@' => contents[:image_link],
        '@image@' => contents[:image],
        '@body_beginning@' => contents[:body_beginning],
        '@body@' => contents[:body],
        '@user@' => contents[:user],
        '@comment_count@' => contents[:comment_count],
      }).html_safe
    end
  end

  def file_path_expanded_body(doc)
    doc.body.gsub(/("|')file_contents\//){|m| %Q(#{$1}#{doc.public_uri(without_filename: true)}file_contents/) }
  end
end
