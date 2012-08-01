# encoding: utf-8
module PublicBbs::CategoryHelper
  def category_tree(category, base_url='')
    li_tags = category.public_children.inject('') {|cats, pc|
      cats << "<li>#{link_to pc.title, "#{base_url}#{pc.name}/"} #{category_tree(pc, base_url)}</li>"
    }
    return '' if li_tags.blank?
    "<ul>#{li_tags}</ul>".html_safe
  end
end
