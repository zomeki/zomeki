# encoding: utf-8
class GpCategory::Public::Node::CategoriesController < Cms::Controller::Public::Base
  include GpArticle::Controller::Feed

  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
    @more = (params[:file] == 'more')
  end

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
        rendered = template.body.gsub(/\[\[module\/([\w-]+)\]\]/) do |matched|
            tm = @content.template_modules.find_by_name($1)
            next unless tm

            case tm.module_type
            when 'categories_1', 'categories_2', 'categories_3'
              view_context.send(tm.module_type, template_module: tm,
                                categories: @category.public_children) if view_context.respond_to?(tm.module_type)
            when 'docs_1', 'docs_2', 'docs_5', 'docs_6'
              docs = case tm.module_type
                     when 'docs_1', 'docs_5'
                       find_public_docs_with_category_ids(@category.public_descendants.map(&:id))
                     when 'docs_2', 'docs_6'
                       find_public_docs_with_category_ids([@category.id])
                     end
              docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

              docs = docs.limit(tm.num_docs).order('display_published_at DESC, published_at DESC')
              view_context.send(tm.module_type, template_module: tm,
                                category: @category, docs: docs) if view_context.respond_to?(tm.module_type)
            when 'docs_3', 'docs_4'
              docs = case tm.module_type
                     when 'docs_3'
                       find_public_docs_with_category_ids(@category.public_descendants.map(&:id))
                     when 'docs_4'
                       find_public_docs_with_category_ids([@category.id])
                     end
              docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

              categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorizable_id: docs.pluck(:id), categorized_as: 'GpArticle::Doc')
              if view_context.respond_to?(tm.module_type) && category_type.internal_category_type
                view_context.send(tm.module_type, template_module: tm,
                                  categories: category_type.internal_category_type.public_root_categories, categorizations: categorizations)
              end
            when 'docs_7', 'docs_8'
              docs = case tm.module_type
                     when 'docs_7', 'docs_8'
                       find_public_docs_with_category_ids(@category.public_descendants.map(&:id))
                     end
              docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

              categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorizable_id: docs.pluck(:id), categorized_as: 'GpArticle::Doc')
              view_context.send(tm.module_type, template_module: tm,
                                categories: @category.children, categorizations: categorizations) if view_context.respond_to?(tm.module_type)
            else
              ''
            end
          end

        render text: rendered
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

  private

  def find_public_docs_with_category_ids(category_ids)
    GpArticle::Doc.all_with_content_and_criteria(nil, category_id: category_ids).except(:order).mobile(::Page.mobile?).public
  end
end
