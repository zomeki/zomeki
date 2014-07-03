# encoding: utf-8
class Tool::Convert::PageParser

  def parse(file_path, uri_path, conf)
    page = Tool::Convert::PageInfo.new
    page.file_path = file_path
    page.uri_path = uri_path

    html = Nokogiri::HTML(open(page.file_path))
    page.title = html.xpath(conf.title_xpath).inner_text.strip
    page.body = html.xpath(conf.body_xpath).inner_html
    page.updated_at = html.xpath(conf.updated_at_xpath).inner_html

    if conf.updated_at_regexp.present? && page.updated_at =~ Regexp.new(conf.updated_at_regexp)
      page.updated_at = "#{$1}-#{$2}-#{$3}"
    end

    if conf.creator_group_from_url_regexp.present? && uri_path =~ Regexp.new(conf.creator_group_from_url_regexp)
      page.group_code = $1
      if group = Sys::Group.find_by_code(page.group_code)
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

    return page
  end
end
