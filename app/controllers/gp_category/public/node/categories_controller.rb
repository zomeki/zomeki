# encoding: utf-8
class GpCategory::Public::Node::CategoriesController < GpCategory::Public::Node::BaseController
  def show
    category_type = @content.category_types.find_by_name(params[:category_type_name])
    @category = category_type.find_category_by_path_from_root_category(params[:category_names])
    return http_error(404) unless @category.try(:public?)

    if params[:format].in?('rss', 'atom')
      docs = @category.public_docs.order('display_published_at DESC, published_at DESC')
      docs = docs.display_published_after(@content.feed_docs_period.to_i.days.ago) if @content.feed_docs_period.present?
      docs = docs.paginate(page: params[:page], per_page: @content.feed_docs_number)
      return render_feed(docs)
    end

    Page.current_item = @category
    Page.title = @category.title

    per_page = (@more ? 30 : @content.category_docs_number)

    if (template = @category.inherited_template)
      if @more
        @docs = @category.public_docs.order('display_published_at DESC, published_at DESC')
                                     .paginate(page: params[:page], per_page: per_page)
        return http_error(404) if @docs.current_page > @docs.total_pages
        render :more
      else
        vc = view_context
        rendered = template.body.gsub(/\[\[module\/([\w-]+)\]\]/) do |matched|
            tm = @content.template_modules.find_by_name($1)
            next unless tm

            case tm.module_type
            when 'categories_1', 'categories_2', 'categories_3'
              if vc.respond_to?(tm.module_type)
                @category.public_children.inject(''){|tags, child|
                  tags << vc.content_tag(:section, class: child.name) do
                      html = vc.content_tag(:h2, vc.link_to(child.title, child.public_uri))
                      html << vc.send(tm.module_type, template_module: tm,
                                      categories: child.public_children)
                    end
                }
              end
            when 'docs_1', 'docs_2'
              if vc.respond_to?(tm.module_type)
                docs = case tm.module_type
                       when 'docs_1'
                         find_public_docs_with_category_ids(@category.public_descendants.map(&:id))
                       when 'docs_2'
                         find_public_docs_with_category_ids([@category.id])
                       end
                docs = docs.where(tm.module_type_feature, true) if docs.columns.any?{|c| c.name == tm.module_type_feature }

                docs = docs.limit(tm.num_docs).order('display_published_at DESC, published_at DESC')
                vc.send(tm.module_type, template_module: tm,
                        ct_or_c: @category, docs: docs)
              end
            when 'docs_3', 'docs_4'
              if vc.respond_to?(tm.module_type) && category_type.internal_category_type
                docs = case tm.module_type
                       when 'docs_3'
                         find_public_docs_with_category_ids(@category.public_descendants.map(&:id))
                       when 'docs_4'
                         find_public_docs_with_category_ids([@category.id])
                       end
                docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

                categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorizable_id: docs.pluck(:id), categorized_as: 'GpArticle::Doc')
                vc.send(tm.module_type, template_module: tm,
                        categories: category_type.internal_category_type.public_root_categories, categorizations: categorizations)
              end
            when 'docs_5', 'docs_6'
              if vc.respond_to?(tm.module_type)
                docs = case tm.module_type
                       when 'docs_5'
                         find_public_docs_with_category_ids(@category.public_descendants.map(&:id))
                       when 'docs_6'
                         find_public_docs_with_category_ids([@category.id])
                       end
                docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

                docs = docs.joins(:creator => :group)
                groups = Sys::Group.where(id: docs.pluck(Sys::Group.arel_table[:id]).uniq)
                vc.send(tm.module_type, template_module: tm,
                        groups: groups, docs: docs)
              end
            when 'docs_7', 'docs_8'
              if view_context.respond_to?(tm.module_type)
                docs = case tm.module_type
                       when 'docs_7', 'docs_8'
                         find_public_docs_with_category_ids(@category.public_descendants.map(&:id))
                       end
                docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

                categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorizable_id: docs.pluck(:id), categorized_as: 'GpArticle::Doc')
                vc.send(tm.module_type, template_module: tm,
                        categories: @category.children, categorizations: categorizations)
              end
            else
              ''
            end
          end

        render text: vc.content_tag(:div, rendered.html_safe, class: 'contentGpCategory contentGpCategoryCategory')
      end
    else
      @docs = @category.public_docs.order('display_published_at DESC, published_at DESC').paginate(page: params[:page], per_page: per_page)
      return http_error(404) if @docs.current_page > @docs.total_pages

      if Page.mobile?
        render :show_mobile
      else
        if @more
          render 'more'
        else
          if (style = @content.category_style).present?
            render style
          end
        end
      end
    end
  end
end
