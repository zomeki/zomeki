# encoding: utf-8
class GpCategory::Public::Piece::RecentTabsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCategory::Piece::RecentTab.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece
  end

  def index
    @more_label = @piece.more_label.presence || '>>新着記事一覧'
    @tabs = []

    GpCategory::Piece::RecentTabXml.find(:all, @piece, :order => :sort_no).each do |tab|
      next if tab.name.blank?

      if (current = @tabs.empty?)
        tab_class = "#{tab.name} current"
      else
        tab_class = tab.name
      end

      unless tab.categories_with_layer.empty?
        doc_ids = tab.categories_with_layer.map do |category_with_layer|
            if category_with_layer[:layer] == 'descendants'
              category_with_layer[:category].descendants.inject([]) {|result, item| result | item.doc_ids }
            else
              category_with_layer[:category].doc_ids
            end
          end

        case tab.condition
        when 'and'
          doc_ids = doc_ids.inject(doc_ids.shift) {|result, item| result & item }
        when 'or'
          doc_ids = doc_ids.inject([]) {|result, item| result | item }
        else
          doc_ids = []
        end
        docs = GpArticle::Doc.mobile(::Page.mobile?).public.where(id: doc_ids).order('published_at DESC').limit(@piece.list_count)
      else
        docs = GpArticle::Doc.mobile(::Page.mobile?).public.order('published_at DESC').limit(@piece.list_count)
      end

      @tabs.push(name: tab.name,
                 title: tab.title,
                 class: tab_class,
                 more: tab.more.presence,
                 current: current,
                 docs: docs)
    end

    render :text => '' if @tabs.empty?
  end
end
