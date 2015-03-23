# encoding: utf-8
module GpArticle::GpArticleHelper
  def link_to_doc_options(doc)
    if doc.target.present?
      if doc.href.present?
        if doc.target == 'attached_file'
          if (file = doc.files.find_by_name(doc.href))
            ["#{doc.public_uri}file_contents/#{file.name}", target: '_blank']
          else
            nil
          end
        else
          [doc.href, target: doc.target]
        end
      else
        nil
      end
    else
      [doc.public_uri]
    end
  end

  def large_flash(flash, key: nil, value: nil)
    raise ArgumentError.new('flash required.') unless flash.kind_of?(ActionDispatch::Flash::FlashHash)

    if value.nil?
      v = flash[key]
      matched = /^flash:(\d+)$/.match(v)
      return v unless matched

      if (text = Sys::TempText.find_by_id(matched[1]))
        text.destroy.content
      else
        nil
      end
    else
      text = Sys::TempText.create(content: value)
      flash[key] = "flash:#{text.id}"
      value
    end
  end

  def og_tags(item)
    return '' if item.nil?
    %w!type title description image!.map{ |key|
      unless item.respond_to?("og_#{key}") && (value = item.send("og_#{key}")).present?
        site = item.respond_to?(:site) ? item.site : item.content.site
        value = site.try("og_#{key}").to_s.gsub("\n", ' ')
        next value.present? ? tag(:meta, property: "og:#{key}", content: value) : nil
      end

      case key
      when 'image'
        if (file = item.image_files.detect{|f| f.name == value })
          tag :meta, property: 'og:image', content: "#{item.content.public_node.public_full_uri}#{item.name}/file_contents/#{url_encode file.name}"
        end
      else
        tag :meta, property: "og:#{key}", content: value.to_s.gsub("\n", ' ')
      end
    }.join.html_safe
  end

  def marker_icon_categories_for_option(map_content_marker)
    table = Map::Content::Setting.arel_table
    settings = Map::Content::Setting.where(content_id: map_content_marker.id)
                                    .where(table[:name].matches('GpCategory::Category % icon_image'))
    options = settings.map do |s|
        next if s.value.blank?
        category_id = /\AGpCategory::Category (\d+) icon_image\z/.match(s.name)[1]
        category = GpCategory::Category.find(category_id)
        ["#{category.title}（#{category.category_type.title}） - #{s.value}", category.id]
      end
    options.compact
  end
end
