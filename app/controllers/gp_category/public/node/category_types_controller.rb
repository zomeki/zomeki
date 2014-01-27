# encoding: utf-8

require 'will_paginate/array'

class GpCategory::Public::Node::CategoryTypesController < Cms::Controller::Public::Base
  include GpArticle::Controller::Feed

  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    if (template = @content.index_template)
      rendered = template.body.gsub(/\[\[module\/([\w-]+)\]\]/) do |matched|
          tm = @content.template_modules.find_by_name($1)
          next unless tm

          case tm.module_type
          when 'categories_1', 'categories_2', 'categories_3'
            if view_context.respond_to?(tm.module_type)
              @content.public_category_types.inject(''){|tags, category_type|
                tags << view_context.content_tag(:section, class: category_type.name) do
                    view_context.send(tm.module_type, template_module: tm,
                                      categories: category_type.public_root_categories)
                  end
              }
            end
          when 'docs_1', 'docs_2', 'docs_5', 'docs_6'
            if view_context.respond_to?(tm.module_type)
              @content.public_category_types.inject(''){|tags, category_type|
                tags << view_context.content_tag(:section, class: category_type.name) do
                    category_type.public_root_categories.inject(''){|ts, category|
                      docs = case tm.module_type
                             when 'docs_1', 'docs_5'
                               find_public_docs_with_category_ids(category.public_descendants.map(&:id))
                             when 'docs_2', 'docs_6'
                               find_public_docs_with_category_ids([category.id])
                             end
                      docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

                      docs = docs.limit(tm.num_docs).order('display_published_at DESC, published_at DESC')
                      ts << view_context.send(tm.module_type, template_module: tm,
                                              category: category, docs: docs)
                    }.html_safe
                  end
              }
            end
          when 'docs_3', 'docs_4'
            if view_context.respond_to?(tm.module_type)
              @content.public_category_types.inject(''){|tags, category_type|
                tags << view_context.content_tag(:section, class: category_type.name) do
                    category_type.public_root_categories.inject(''){|ts, category|
                      docs = case tm.module_type
                             when 'docs_3'
                               find_public_docs_with_category_ids(category.public_descendants.map(&:id))
                             when 'docs_4'
                               find_public_docs_with_category_ids([category.id])
                             end
                      docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

                      categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorizable_id: docs.pluck(:id), categorized_as: 'GpArticle::Doc')
                      ts << if category_type.internal_category_type
                              view_context.send(tm.module_type, template_module: tm,
                                                categories: category_type.internal_category_type.public_root_categories, categorizations: categorizations)
                            else
                              ''
                            end
                    }.html_safe
                  end
              }
            end
          when 'docs_7', 'docs_8'
            if view_context.respond_to?(tm.module_type)
              @content.public_category_types.inject(''){|tags, category_type|
                tags << view_context.content_tag(:section, class: category_type.name) do
                    category_type.public_root_categories.inject(''){|ts, category|
                      docs = case tm.module_type
                             when 'docs_7', 'docs_8'
                               find_public_docs_with_category_ids(category.public_descendants.map(&:id))
                             end
                      docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

                      categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorizable_id: docs.pluck(:id), categorized_as: 'GpArticle::Doc')
                      ts << view_context.send(tm.module_type, template_module: tm,
                                              categories: category.children, categorizations: categorizations)
                    }.html_safe
                  end
              }
            end
          else
            ''
          end
        end

      render text: rendered
    else
      @category_types = @content.public_category_types.paginate(page: params[:page], per_page: 20)
      return http_error(404) if @category_types.current_page > @category_types.total_pages

      render :index_mobile if Page.mobile?
    end
  end

  def show
    @category_type = @content.public_category_types.find_by_name(params[:name])
    return http_error(404) unless @category_type

    if params[:format].in?('rss', 'atom')
      case @content.category_type_style
      when 'all_docs'
        category_ids = @category_type.public_categories.pluck(:id)
        @docs = find_public_docs_with_category_ids(category_ids).order('display_published_at DESC, published_at DESC')
        @docs = @docs.display_published_after(@content.feed_docs_period.to_i.days.ago) if @content.feed_docs_period.present?
        @docs = @docs.paginate(page: params[:page], per_page: @content.feed_docs_number)
        return render_feed(@docs)
      else
        return http_error(404)
      end
    end

    Page.current_item = @category_type
    Page.title = @category_type.title

    case @content.category_type_style
    when 'all_docs'
      category_ids = @category_type.public_categories.pluck(:id)
      @docs = find_public_docs_with_category_ids(category_ids).order('display_published_at DESC, published_at DESC')
      @docs = @docs.paginate(page: params[:page], per_page: @content.category_type_docs_number)
      return http_error(404) if @docs.current_page > @docs.total_pages
    else
      return http_error(404) if params[:page].to_i > 1
    end

    if Page.mobile?
      render :show_mobile
    else
      if (style = @content.category_type_style).present?
        render style
      end
    end
  end

  private

  def find_public_docs_with_category_ids(category_ids)
    GpArticle::Doc.all_with_content_and_criteria(nil, category_id: category_ids).except(:order).mobile(::Page.mobile?).public
  end
end
