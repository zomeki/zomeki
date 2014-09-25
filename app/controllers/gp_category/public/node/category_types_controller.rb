# encoding: utf-8

require 'will_paginate/array'

class GpCategory::Public::Node::CategoryTypesController < GpCategory::Public::Node::BaseController
  def index
    if (template = @content.index_template)
      return http_error(404) if params[:page]

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
          when 'docs_1'
            if vc.respond_to?(tm.module_type)
              category_ids = @content.public_category_types.inject([]){|ids, category_type|
                ids.concat(category_type.public_root_categories.inject([]){|is, category|
                  is.concat(category.public_descendants.map(&:id))
                })
              }

              docs = find_public_docs_with_category_id(category_ids)
              docs = docs.where(tm.module_type_feature, true) if docs.columns.any?{|c| c.name == tm.module_type_feature }

              all_docs = docs.order('display_published_at DESC, published_at DESC')
              docs = all_docs.limit(tm.num_docs)
              vc.send(tm.module_type, template_module: tm,
                      ct_or_c: nil, docs: docs, all_docs: all_docs)
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
        @docs = find_public_docs_with_category_id(category_ids).order('display_published_at DESC, published_at DESC')
        @docs = @docs.display_published_after(@content.feed_docs_period.to_i.days.ago) if @content.feed_docs_period.present?
        @docs = @docs.paginate(page: params[:page], per_page: @content.feed_docs_number)
        return render_feed(@docs)
      else
        return http_error(404)
      end
    end

    Page.current_item = @category_type
    Page.title = @category_type.title

    per_page = (@more ? 30 : @content.category_type_docs_number)

    if (template = @category_type.template)
      if @more
        category_ids = @category_type.public_root_categories.inject([]){|ids, category|
          ids.concat(category.public_descendants.map(&:id))
        }
        @docs = find_public_docs_with_category_id(category_ids)

        feature = case
                  when 'f1'.in?(@more_options)
                    'feature_1'
                  when 'f2'.in?(@more_options)
                    'feature_2'
                  else
                    ''
                  end
        @docs = @docs.where(feature, true) if @docs.columns.any?{|c| c.name == feature }

        filter = @more_options.detect{|o| o =~ /^(c|g)_/i }
        if filter
          prefix, code_or_name = filter.split('_', 2)

          case prefix
          when 'c'
            return http_error(404) unless @category_type.internal_category_type

            internal_category = @category_type.internal_category_type.public_root_categories.find_by_name(code_or_name)
            return http_error(404) unless internal_category

            categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorized_as: 'GpArticle::Doc',
                                                               categorizable_id: @docs.pluck(:id),
                                                               category_id: internal_category.public_descendants.map(&:id))
            @docs = GpArticle::Doc.where(id: categorizations.pluck(:categorizable_id))
          when 'g'
            @docs = @docs.joins(:creator => :group).where(Sys::Group.arel_table[:code].eq(code_or_name))
          end
        end

        @docs = @docs.order('display_published_at DESC, published_at DESC').paginate(page: params[:page], per_page: per_page)
        return http_error(404) if @docs.current_page > @docs.total_pages
        render :more
      else
        return http_error(404) if params[:page]

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
            when 'docs_1'
              if vc.respond_to?(tm.module_type)
                category_ids = @category_type.public_root_categories.inject([]){|ids, category|
                  ids.concat(category.public_descendants.map(&:id))
                }

                docs = find_public_docs_with_category_id(category_ids)
                docs = docs.where(tm.module_type_feature, true) if docs.columns.any?{|c| c.name == tm.module_type_feature }

                all_docs = docs.order('display_published_at DESC, published_at DESC')
                docs = all_docs.limit(tm.num_docs)
                vc.send(tm.module_type, template_module: tm,
                        ct_or_c: @category_type, docs: docs, all_docs: all_docs)
              end
            when 'docs_3'
              if vc.respond_to?(tm.module_type) && @category_type.internal_category_type
                category_ids = @category_type.public_root_categories.inject([]){|ids, category|
                  ids.concat(category.public_descendants.map(&:id))
                }

                docs = find_public_docs_with_category_id(category_ids)
                docs = docs.where(tm.module_type_feature, true) if docs.columns.any?{|c| c.name == tm.module_type_feature }

                categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorizable_id: docs.pluck(:id), categorized_as: 'GpArticle::Doc')
                vc.send(tm.module_type, template_module: tm,
                        ct_or_c: @category_type,
                        categories: @category_type.internal_category_type.public_root_categories, categorizations: categorizations)
              end
            when 'docs_5'
              if vc.respond_to?(tm.module_type)
                category_ids = @category_type.public_root_categories.inject([]){|ids, category|
                  ids.concat(category.public_descendants.map(&:id))
                }

                docs = find_public_docs_with_category_id(category_ids)
                docs = docs.where(tm.module_type_feature, true) if docs.columns.any?{|c| c.name == tm.module_type_feature }

                docs = docs.joins(:creator => :group)
                groups = Sys::Group.where(id: docs.pluck(Sys::Group.arel_table[:id]).uniq)
                vc.send(tm.module_type, template_module: tm,
                        ct_or_c: @category_type,
                        groups: groups, docs: docs)
              end
            when 'docs_7', 'docs_8'
              if vc.respond_to?(tm.module_type)
                category_ids = @category_type.public_root_categories.inject([]){|ids, category|
                  ids.concat(category.public_descendants.map(&:id))
                }

                docs = find_public_docs_with_category_id(category_ids)
                docs = docs.where(tm.module_type_feature, true) if docs.columns.any?{|c| c.name == tm.module_type_feature }

                categorizations = GpCategory::Categorization.where(categorizable_type: 'GpArticle::Doc', categorizable_id: docs.pluck(:id), categorized_as: 'GpArticle::Doc')
                vc.send(tm.module_type, template_module: tm,
                        categories: @category_type.public_root_categories, categorizations: categorizations)
              end
            else
              ''
            end
          end

        render text: vc.content_tag(:div, rendered.html_safe, class: 'contentGpCategory contentGpCategoryCategoryType')
      end
    else
      case @content.category_type_style
      when 'all_docs'
        category_ids = @category_type.public_categories.pluck(:id)
        @docs = find_public_docs_with_category_id(category_ids).order('display_published_at DESC, published_at DESC')
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
