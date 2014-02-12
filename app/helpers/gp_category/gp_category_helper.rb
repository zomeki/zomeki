module GpCategory::GpCategoryHelper
  def public_docs_with_category_id(category_id)
    GpArticle::Doc.all_with_content_and_criteria(nil, category_id: category_id).except(:order).mobile(::Page.mobile?).public
  end

  def category_li(category, depth_limit: 1000, depth: 1)
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

  def categories_1(template_module: nil, categories: nil)
    return if categories.empty?

    content_tag(:ul) do
      categories.inject(''){|lis, child|
        lis << category_li(child)
      }.html_safe
    end
  end

  def categories_2(template_module: nil, categories: nil)
  end

  def categories_3(template_module: nil, categories: nil)
    return if categories.empty?

    content_tag(:ul) do
      categories.inject(''){|lis, child|
        lis << category_li(child, depth_limit: 1)
      }.html_safe
    end
  end

  def docs_1(template_module: nil, ct_or_c: nil, docs: nil)
    content_tag(:section, class: template_module.name) do
      html = docs.inject(''){|tags, doc|
          tags << content_tag(template_module.wrapper_tag) do
              doc_replace(doc, template_module.doc_style, @content.date_style, @content.time_style)
            end
        }.html_safe
      html = content_tag(:ul, html) if template_module.wrapper_tag == 'li'
      if ct_or_c
        html << content_tag(:div, link_to('一覧へ', "#{ct_or_c.public_uri}more.html"), class: 'more')
      else
        html
      end
    end
  end

  def docs_2(template_module: nil, ct_or_c: nil, docs: nil)
    docs_1(template_module: template_module, ct_or_c: ct_or_c, docs: docs)
  end

  def docs_3(template_module: nil, categories: nil, categorizations: nil)
    content_tag(:section, class: template_module.name) do
      categories.inject(''){|tags, category|
        tags << content_tag(:section, class: category.name) do
            cats = categorizations.where(category_id: category.public_descendants.map(&:id))
            next if cats.empty?

            docs = cats.first.categorizable_type.constantize.where(id: cats.pluck(:categorizable_id))
                                                            .limit(template_module.num_docs).order('display_published_at DESC, published_at DESC')
            html = content_tag(:h2, category.title) << content_tag(:ul) do
                docs.inject(''){|t, d|
                  t << content_tag(:li, doc_replace(d, template_module.doc_style, @content.date_style, @content.time_style))
                }.html_safe
              end
            html << content_tag(:div, link_to('一覧へ', "#{category.public_uri}more.html"), class: 'more')
          end
      }.html_safe
    end
  end

  def docs_4(template_module: nil, categories: nil, categorizations: nil)
    docs_3(template_module: template_module, categories: categories, categorizations: categorizations)
  end

  def docs_5(template_module: nil, groups: nil, docs: nil)
    content_tag(:section, class: template_module.name) do
      groups.inject(''){|tags, group|
        tags << content_tag(:section, class: group.code) do
            docs = docs.where(Sys::Group.arel_table[:id].eq(group.id))
                       .limit(template_module.num_docs).order('display_published_at DESC, published_at DESC')

            content_tag(:h2, group.name) << content_tag(:ul) do
                docs.inject(''){|t, d|
                  t << content_tag(:li, doc_replace(d, template_module.doc_style, @content.date_style, @content.time_style))
                }.html_safe
              end
          end
      }.html_safe
    end
  end

  def docs_6(template_module: nil, groups: nil, docs: nil)
    docs_5(template_module: template_module, groups: groups, docs: docs)
  end

  def docs_7(template_module: nil, categories: nil, categorizations: nil)
    content_tag(:section, class: template_module.name) do
      categories.inject(''){|tags, category|
        tags << category_section(category, template_module: template_module, categorizations: categorizations, with_child_categories: false)
      }.html_safe
    end
  end

  def docs_8(template_module: nil, categories: nil, categorizations: nil)
    content_tag(:section, class: template_module.name) do
      categories.inject(''){|tags, category|
        tags << category_section(category, template_module: template_module, categorizations: categorizations, with_child_categories: true)
      }.html_safe
    end
  end

  def category_section(category, template_module: nil, categorizations: nil, with_child_categories: nil)
    content_tag(:section, class: category.name) do
      cats = categorizations.where(category_id: category.public_descendants.map(&:id))
      next if cats.empty?

      docs = cats.first.categorizable_type.constantize.where(id: cats.pluck(:categorizable_id))
                                                      .limit(template_module.num_docs).order('display_published_at DESC, published_at DESC')
      html = content_tag(:h2, category.title) << content_tag(:ul) do
          docs.inject(''){|t, d|
            t << content_tag(:li, doc_replace(d, template_module.doc_style, @content.date_style, @content.time_style))
          }.html_safe
        end

      if with_child_categories && category.children.present?
        html << content_tag(:section) do
            content_tag(:ul) do
              category.children.inject(''){|tags, child|
                tags << content_tag(:li, link_to(child.title, child.public_uri))
              }.html_safe
            end
          end
      end

      html << content_tag(:div, link_to('一覧へ', "#{category.public_uri}more.html"), class: 'more')
    end
  end
end
