module GpCategory::GpCategoryHelper
  def category_li(category, depth_limit: 100, depth: 1)
    content_tag(:li) do
      result = link_to(category.title, category.public_uri)
      if category.public_children.empty? || depth >= depth_limit
        result
      else
        result << content_tag(:ul) do
            category.public_children.inject(''){|lis, child|
              lis << category_li(child, depth_limit: depth_limit, depth: depth + 1)
            }.html_safe
          end
      end
    end
  end

  def categories_1(category:, template_module:, docs:)
    return if category.public_children.empty?

    content_tag(:ul) do
      category.public_children.inject(''){|lis, child|
        lis << category_li(child)
      }.html_safe
    end
  end

  def categories_2(category:, template_module:, docs:)
    return if category.public_children.empty?

    content_tag(:ul) do
      category.public_children.inject(''){|lis, child|
        lis << category_li(child, depth_limit: 1)
      }.html_safe
    end
  end

  def categories_3(category:, template_module:, docs:)
    return if category.public_children.empty?

    content_tag(:ul) do
      category.public_children.inject(''){|lis, child|
        lis << category_li(child, depth_limit: 2)
      }.html_safe
    end
  end

  def docs_1(category:, template_module:, docs:)
    content_tag(:section, class: template_module.name) do
      html = docs.inject(''){|tags, doc|
          tags << content_tag(template_module.wrapper_tag) do
              doc_replace(doc, template_module.doc_style, @content.date_style, @content.time_style)
            end
        }.html_safe
      template_module.wrapper_tag == 'li' ? content_tag(:ul, html) : html
    end
  end

  def docs_2(category:, template_module:, docs:)
    docs_1(category: category, template_module: template_module, docs: docs)
  end

#TODO: docs_3-docs_8
end
