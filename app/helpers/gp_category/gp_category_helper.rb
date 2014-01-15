module GpCategory::GpCategoryHelper
  def categories_1(category:, template_module:, docs:)
    return if category.public_children.empty?

    content_tag(:ul) do
      category.public_children.inject(''){|lis, child|
        lis << category_li(child)
      }.html_safe
    end
  end

  def category_li(category)
    content_tag(:li) do
      result = link_to(category.title, category.public_uri)
      if category.public_children.empty?
        result
      else
        result << content_tag(:ul) do
            category.public_children.inject(''){|lis, child|
              lis << category_li(child)
            }.html_safe
          end
      end
    end
  end
end
