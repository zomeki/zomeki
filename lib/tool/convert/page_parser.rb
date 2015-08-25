# encoding: utf-8
class Tool::Convert::PageParser

  def parse(file_path, uri_path, conf)
    require 'kconv'
    page = Tool::Convert::PageInfo.new
    page.file_path = file_path
    page.uri_path = uri_path

    html = open(page.file_path, "r:binary").read
    html = Nokogiri::HTML(html.toutf8, nil, 'utf-8')

    page.title = html.xpath(conf.title_xpath).inner_text.strip
    page.body = html.xpath(conf.body_xpath).inner_html

    page.updated_at = html.xpath(conf.updated_at_xpath).inner_html unless conf.updated_at_xpath.blank?

    if page.updated_at.blank?
      file = ::File::stat(page.file_path)
      page.updated_at = file.mtime.strftime("%Y-%m-%d")
    end

    if conf.updated_at_regexp.present? && page.updated_at =~ Regexp.new(conf.updated_at_regexp)
      page.updated_at = "#{$1}-#{$2}-#{$3}"
    end
    if conf.creator_group_from_url_regexp.present? && uri_path =~ Regexp.new(conf.creator_group_from_url_regexp)
      page.group_code = $1

      # convert group string
      page.group_code = conf.creator_group_url_relations_map[page.group_code] if conf.creator_group_url_relations_map.has_key?(page.group_code)

      if conf.relate_url_to_group_name_en?
        group = Sys::Group.find_by_name_en(page.group_code)
      elsif conf.relate_url_to_group_name?
        group = Sys::Group.find_by_name(page.group_code)
      else
        group = Sys::Group.find_by_code(page.group_code)
      end

      if group
        page.creator_group_id = group.id
        page.creator_user_id = Sys::User.where("name like '#{group.name}%'").first.try(:id)

        page.inquiry_group_id = group.id
        page.inquiry_group_tel = group.tel
        page.inquiry_group_fax = group.fax
        page.inquiry_group_email = group.email

        if category = GpCategory::Category.where(title: group.name).first
          page.category_ids = [category.id]
        end
      end
    end

    page.category_name = nil
    page.category_name = html.xpath(conf.category_xpath).inner_html unless conf.category_xpath.blank?

    if conf.category_regexp.present? && page.category_name =~ Regexp.new(conf.category_regexp)
      page.category_name = $1
    elsif conf.category_xpath.blank? && conf.category_regexp.present? && html.inner_html =~ Regexp.new(conf.category_regexp)
      page.category_name = $1
    end
    dump "抜き出しカテゴリ名：#{page.category_name}" if page.category_name.present?

    return page
  end
end
