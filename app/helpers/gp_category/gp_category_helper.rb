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

  def docs_1(template_module:, list_url:, docs:)
    content_tag(:section, class: template_module.name) do
      html = docs.inject(''){|tags, doc|
          tags << content_tag(template_module.wrapper_tag) do
              doc_replace(doc, template_module.doc_style, @content.date_style, @content.time_style)
            end
        }.html_safe
      html = template_module.wrapper_tag == 'li' ? content_tag(:ul, html) : html
      html << content_tag(:div, link_to('一覧へ', list_url), class: 'more')
    end
  end

  def docs_2(template_module:, list_url:, docs:)
    docs_1(template_module: template_module, list_url: list_url, docs: docs)
  end

  def docs_3(template_module:, list_url:, categories:, categorizations:)
    content_tag(:section, class: template_module.name) do
      html = categories.inject(''){|tags, category|
          tags << content_tag(:section, class: category.name) do
              cats = categorizations.where(category_id: category.public_descendants.map(&:id))
              next if cats.empty?

              docs = cats.first.categorizable_type.constantize.where(id: cats.pluck(:categorizable_id))
                                                              .limit(template_module.num_docs).order('display_published_at DESC, published_at DESC')
              content_tag(:h2, category.title) << content_tag(:ul) do
                  docs.inject(''){|t, d|
                    t << content_tag(:li, doc_replace(d, template_module.doc_style, @content.date_style, @content.time_style))
                  }.html_safe
                end
            end
        }.html_safe
      html << content_tag(:div, link_to('一覧へ', list_url), class: 'more')
    end
  end

  def docs_4(template_module:, list_url:, categories:, categorizations:)
    docs_3(template_module: template_module, list_url: list_url, categories: categories, categorizations: categorizations)
  end

  def docs_5(template_module:, list_url:, docs:)
    docs = docs.joins(:creator => :group)
    group_ids = docs.pluck(Sys::Group.arel_table[:id]).uniq
    groups = Sys::Group.where(id: group_ids)

    content_tag(:section, class: template_module.name) do
      html = groups.inject(''){|tags, group|
          tags << content_tag(:section, class: group.code) do
              docs = docs.where(Sys::Group.arel_table[:id].eq(group.id))

              content_tag(:h2, group.name) << content_tag(:ul) do
                  docs.inject(''){|t, d|
                    t << content_tag(:li, doc_replace(d, template_module.doc_style, @content.date_style, @content.time_style))
                  }.html_safe
                end
            end
        }.html_safe
      html << content_tag(:div, link_to('一覧へ', list_url), class: 'more')
    end
  end

  def docs_6(template_module:, list_url:, docs:)
    docs_5(template_module: template_module, list_url: list_url, docs: docs)
  end

  def docs_7(template_module:, list_url:, categories:, categorizations:)
    content_tag(:section, class: template_module.name) do
      html = categories.inject(''){|tags, category|
          tags << content_tag(:section, class: category.name) do
              cats = categorizations.where(category_id: category.public_descendants.map(&:id))
              next if cats.empty?

              docs = cats.first.categorizable_type.constantize.where(id: cats.pluck(:categorizable_id))
                                                              .limit(template_module.num_docs).order('display_published_at DESC, published_at DESC')
              content_tag(:h2, category.title) << content_tag(:ul) do
                  docs.inject(''){|t, d|
                    t << content_tag(:li, doc_replace(d, template_module.doc_style, @content.date_style, @content.time_style))
                  }.html_safe
                end
            end
        }.html_safe
      html << content_tag(:div, link_to('一覧へ', list_url), class: 'more')
    end
  end

  def docs_8(template_module:, list_url:, categories:, categorizations:)
    content_tag(:section, class: template_module.name) do
#TODO: つぎここ
    end
  end
end
