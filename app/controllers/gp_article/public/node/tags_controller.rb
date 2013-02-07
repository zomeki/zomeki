# encoding: utf-8
class GpArticle::Public::Node::TagsController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = GpArticle::Content::Doc.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    if @content.tags.empty?
      http_error(404)
    else
      redirect_to "#{@node.public_uri}#{CGI::escape(@content.tags.first.word)}/"
    end
  end

  def show
    @item = @content.tags.find_by_word(params[:word])
    return http_error(404) unless @item

    Page.current_item = @item
    Page.title = @item.word

    @docs = @item.public_docs
  end
end
