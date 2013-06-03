# encoding: utf-8
class GpArticle::Public::Piece::RecentTabsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpArticle::Piece::RecentTab.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece
  end

  def index
    @more_label = @piece.more_label.presence || '>>新着記事一覧'
    @tabs = []

    GpArticle::Piece::RecentTabXml.find(:all, @piece, :order => :sort_no).each do |tab|
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
        docs = @piece.content.public_docs.where(id: doc_ids).order('published_at DESC').limit(@piece.list_count)
      else
        docs = @piece.content.public_docs.order('published_at DESC').limit(@piece.list_count)
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
