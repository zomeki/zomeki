# encoding: utf-8
module GpTemplate::GpTemplateHelper
  def template_body(template, template_values, files)
    template.items.inject(template.body.to_s) do |body, item|
      body.gsub(/\[\[item\/#{item.name}\]\]/, template_item_value(item, template_values[item.name].to_s, files))
    end
  end

  def template_item_value(item, value, files)
    return '' if item.state_closed?
    
    case item.item_type
    when 'text_area'
      value = br(value)
    when 'attachment_file'
      if file = files.detect {|f| f.name == value }
        if file.image_is == 1
          value = content_tag('image', '', src: "file_contents/#{file.name}", title: file.title) 
        else
          value = content_tag('a', file.united_name, href: "file_contents/#{file.name}", class: file.css_class)
        end
      end
    end
    value
  end
end
