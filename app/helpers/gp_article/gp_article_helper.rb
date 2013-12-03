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
      next unless item.respond_to?("og_#{key}") && (value = item.send("og_#{key}")).present?

      case key
      when 'description'
        value = strip_tags(item.body) if item.og_description_use_body
        tag :meta, property: 'og:description', content: value.to_s.gsub("\n", ' ')
      when 'image'
        if (file = item.image_files.detect{|f| f.name == value })
          tag :meta, property: 'og:image', content: "#{item.content.public_node.public_full_uri}#{item.name}/file_contents/#{url_encode file.name}"
        end
      else
        tag :meta, property: "og:#{key}", content: value
      end
    }.join.html_safe
  end
end
