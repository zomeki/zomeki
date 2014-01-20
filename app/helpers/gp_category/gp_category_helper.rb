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

  def categories_1(template_module:, category:)
    return if category.public_children.empty?

    content_tag(:ul) do
      category.public_children.inject(''){|lis, child|
        lis << category_li(child)
      }.html_safe
    end
  end

  def categories_2(template_module:, category:)
    return if category.public_children.empty?

    content_tag(:ul) do
      category.public_children.inject(''){|lis, child|
        lis << category_li(child, depth_limit: 1)
      }.html_safe
    end
  end

  def categories_3(template_module:, category:)
    return if category.public_children.empty?

    content_tag(:ul) do
      category.public_children.inject(''){|lis, child|
        lis << category_li(child, depth_limit: 2)
      }.html_safe
    end
  end

  def docs_1(template_module:, docs:)
    content_tag(:section, class: template_module.name) do
      html = docs.inject(''){|tags, doc|
          tags << content_tag(template_module.wrapper_tag) do
              doc_replace(doc, template_module.doc_style, @content.date_style, @content.time_style)
            end
        }.html_safe
      template_module.wrapper_tag == 'li' ? content_tag(:ul, html) : html
    end
  end

  def docs_2(template_module:, docs:)
    docs_1(template_module: template_module, docs: docs)
  end

  def docs_3(template_module:, internal_category_type:, categorizations:)
    content_tag(:section, class: template_module.name) do
      internal_category_type.public_root_categories.inject(''){|tags, root_category|
        tags << content_tag(:section, class: root_category.name) do
            cats = categorizations.where(category_id: root_category.public_descendants.map(&:id))
            next if cats.empty?

            docs = cats.first.categorizable_type.constantize.where(id: cats.pluck(:categorizable_id))
                                                            .limit(template_module.num_docs).order('display_published_at DESC, published_at DESC')
            content_tag(:h2, root_category.title) << content_tag(:ul) do
                docs.inject(''){|t, d|
                  t << content_tag(:li, doc_replace(d, template_module.doc_style, @content.date_style, @content.time_style))
                }.html_safe
              end
          end
      }.html_safe
    end
  end

  def docs_4(template_module:, internal_category_type:, categorizations:)
    docs_3(template_module: template_module, internal_category_type: internal_category_type, categorizations: categorizations)
  end

  def docs_5(template_module:, docs:)
    docs = docs.joins(:creator => :group)
    group_ids = docs.pluck(Sys::Group.arel_table[:id]).uniq
    groups = Sys::Group.where(id: group_ids)

    content_tag(:section, class: template_module.name) do
      groups.inject(''){|tags, group|
        tags << content_tag(:section, class: group.code) do
            docs = docs.where(Sys::Group.arel_table[:id].eq(group.id))

            content_tag(:h2, group.name) << content_tag(:ul) do
                docs.inject(''){|t, d|
                  t << content_tag(:li, doc_replace(d, template_module.doc_style, @content.date_style, @content.time_style))
                }.html_safe
              end
          end
      }.html_safe
    end
  end

  def docs_6(template_module:, docs:)
    docs_5(template_module: template_module, docs: docs)
  end

#TODO: docs_7-docs_8
end
