class GpArticle::Public::Node::CommentsController < Cms::Controller::Public::Base
  def pre_dispatch
    @content = GpArticle::Content::Doc.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content

    return http_error(404) unless @content.blog_functions[:comment]

    @doc = @content.public_docs.find_by_name(params[:name])
    return http_error(404) unless @doc
  end

  def create
    comment = @doc.comments.build(params[:comment])
    comment.remote_addr = request.remote_addr
    comment.user_agent = request.user_agent
    comment.state = (@content.blog_functions[:comment_open] ? GpArticle::Comment::STATE_OPTIONS.first
                                                            : GpArticle::Comment::STATE_OPTIONS.last).last
    comment.save

    redirect_to @doc.public_full_uri
  end
end
