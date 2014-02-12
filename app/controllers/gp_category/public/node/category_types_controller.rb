# encoding: utf-8

require 'will_paginate/array'

class GpCategory::Public::Node::CategoryTypesController < GpCategory::Public::Node::BaseController
  def index
    if (template = @content.index_template)
      vc = view_context
      rendered = template.body.gsub(/\[\[module\/([\w-]+)\]\]/) do |matched|
          tm = @content.template_modules.find_by_name($1)
          next unless tm

          case tm.module_type
          when 'categories_1', 'categories_2', 'categories_3'
            if vc.respond_to?(tm.module_type)
              @content.public_category_types.inject(''){|tags, category_type|
                tags << vc.content_tag(:section, class: category_type.name) do
                    html = vc.content_tag(:h2, vc.link_to(category_type.title, category_type.public_uri))
                    html << vc.send(tm.module_type, template_module: tm,
                                    categories: category_type.public_root_categories)
                  end
              }
            end
          when 'docs_1', 'docs_2'
            if vc.respond_to?(tm.module_type)
              @content.public_category_types.inject(''){|tags, category_type|
                tags << vc.content_tag(:section, class: category_type.name) do
                    html = vc.content_tag(:h2, category_type.title)
                    html << category_type.public_root_categories.inject(''){|ts, category|
                              docs = case tm.module_type
                                     when 'docs_1'
                                       find_public_docs_with_category_ids(category.public_descendants.map(&:id))
                                     when 'docs_2'
                                       find_public_docs_with_category_ids([category.id])
                                     end
                              docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

                              docs = docs.limit(tm.num_docs).order('display_published_at DESC, published_at DESC')
                              ts << vc.send(tm.module_type, template_module: tm,
                                            category: category, docs: docs, header: true)
                            }.html_safe
                  end
              }
            end
          when 'docs_3', 'docs_4'
            if vc.respond_to?(tm.module_type)
              @content.public_category_types.inject(''){|tags, category_type|
                tags << vc.content_tag(:section, class: category_type.name) do
                    html = vc.content_tag(:h2, category_type.title)
                    html << category_type.public_root_categories.inject(''){|ts, category|
                              docs = case tm.module_type
                                     when 'docs_3'
                                       find_public_docs_with_category_ids(category.public_descendants.map(&:id))
                                     when 'docs_4'
                                       find_public_docs_with_category_ids([category.id])
                                     end
                              docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

                              categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorizable_id: docs.pluck(:id), categorized_as: 'GpArticle::Doc')
                              ts << if category_type.internal_category_type
                                      vc.send(tm.module_type, template_module: tm,
                                              categories: category_type.internal_category_type.public_root_categories, categorizations: categorizations)
                                    else
                                      ''
                                    end
                            }.html_safe
                  end
              }
            end
          when 'docs_5', 'docs_6'
            if vc.respond_to?(tm.module_type)
              @content.public_category_types.inject(''){|tags, category_type|
                tags << vc.content_tag(:section, class: category_type.name) do
                    html = vc.content_tag(:h2, category_type.title)

                    docs = case tm.module_type
                           when 'docs_5', 'docs_6'
                             find_public_docs_with_category_ids(category_type.public_categories.pluck(:id))
                           end
                    docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

                    docs = docs.joins(:creator => :group)
                    groups = Sys::Group.where(id: docs.pluck(Sys::Group.arel_table[:id]).uniq)
                    html << vc.send(tm.module_type, template_module: tm,
                                    groups: groups, docs: docs)
                  end
              }
            end
          when 'docs_7', 'docs_8'
            if vc.respond_to?(tm.module_type)
              @content.public_category_types.inject(''){|tags, category_type|
                tags << vc.content_tag(:section, class: category_type.name) do
                    html = vc.content_tag(:h2, category_type.title)
                    html << category_type.public_root_categories.inject(''){|ts, category|
                              docs = case tm.module_type
                                     when 'docs_7', 'docs_8'
                                       find_public_docs_with_category_ids(category.public_descendants.map(&:id))
                                     end
                              docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

                              categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorizable_id: docs.pluck(:id), categorized_as: 'GpArticle::Doc')
                              ts << vc.send(tm.module_type, template_module: tm,
                                            categories: category.children, categorizations: categorizations)
                            }.html_safe
                  end
              }
            end
          else
            ''
          end
        end

      render text: vc.content_tag(:div, rendered.html_safe, class: 'contentGpCategory contentGpCategoryCategoryTypes')
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

    if (template = @category_type.template)
      vc = view_context
      rendered = template.body.gsub(/\[\[module\/([\w-]+)\]\]/) do |matched|
          tm = @content.template_modules.find_by_name($1)
          next unless tm

          case tm.module_type
          when 'categories_1', 'categories_2', 'categories_3'
            if vc.respond_to?(tm.module_type)
              @category_type.public_root_categories.inject(''){|tags, category|
                tags << vc.content_tag(:section, class: category.name) do
                    html = vc.content_tag(:h2, vc.link_to(category.title, category.public_uri))
                    html << vc.send(tm.module_type, template_module: tm,
                                    categories: category.public_children)
                  end
              }
            end
          when 'docs_1', 'docs_2'
            if vc.respond_to?(tm.module_type)
              @category_type.public_root_categories.inject(''){|tags, category|
                docs = case tm.module_type
                       when 'docs_1'
                         find_public_docs_with_category_ids(category.public_descendants.map(&:id))
                       when 'docs_2'
                         find_public_docs_with_category_ids([category.id])
                       end
                docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

                docs = docs.limit(tm.num_docs).order('display_published_at DESC, published_at DESC')
                tags << vc.send(tm.module_type, template_module: tm,
                                category: category, docs: docs, header: true)
              }.html_safe
            end
          when 'docs_3', 'docs_4'
            if vc.respond_to?(tm.module_type)
              @category_type.public_root_categories.inject(''){|tags, category|
                docs = case tm.module_type
                       when 'docs_3'
                         find_public_docs_with_category_ids(category.public_descendants.map(&:id))
                       when 'docs_4'
                         find_public_docs_with_category_ids([category.id])
                       end
                docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

                categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorizable_id: docs.pluck(:id), categorized_as: 'GpArticle::Doc')
                tags << if @category_type.internal_category_type
                          vc.send(tm.module_type, template_module: tm,
                                  categories: @category_type.internal_category_type.public_root_categories, categorizations: categorizations)
                        else
                          ''
                        end
              }.html_safe
            end
          when 'docs_5', 'docs_6'
            if vc.respond_to?(tm.module_type)
              docs = case tm.module_type
                     when 'docs_5', 'docs_6'
                       find_public_docs_with_category_ids(@category_type.public_categories.pluck(:id))
                     end
              docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

              docs = docs.joins(:creator => :group)
              groups = Sys::Group.where(id: docs.pluck(Sys::Group.arel_table[:id]).uniq)
              vc.send(tm.module_type, template_module: tm,
                      groups: groups, docs: docs)
            end
          when 'docs_7', 'docs_8'
            if vc.respond_to?(tm.module_type)
              @category_type.public_root_categories.inject(''){|tags, category|
                docs = case tm.module_type
                       when 'docs_7', 'docs_8'
                         find_public_docs_with_category_ids(category.public_descendants.map(&:id))
                       end
                docs = docs.where(tm.module_type_feature, true) if docs.columns.detect{|c| c.name == tm.module_type_feature }

                categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorizable_id: docs.pluck(:id), categorized_as: 'GpArticle::Doc')
                tags << vc.send(tm.module_type, template_module: tm,
                                categories: category.children, categorizations: categorizations)
              }.html_safe
            end
          else
            ''
          end
        end

      render text: vc.content_tag(:div, rendered.html_safe, class: 'contentGpCategory contentGpCategoryCategoryType')
    else
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
        render @content.category_type_style if @content.category_type_style.present?
      end
    end
  end
end
