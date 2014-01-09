class GpArticle::Public::Node::CommentsController < Cms::Controller::Public::Base
  include SimpleCaptcha::ControllerHelpers

  def pre_dispatch
    @content = GpArticle::Content::Doc.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content

    return http_error(404) unless @content.blog_functions[:comment]

    @doc = @content.public_docs.find_by_name(params[:name])
    return http_error(404) unless @doc
  end

  def new
    @comment = @doc.comments.build
  end

  def confirm
    @comment = @doc.comments.build(params[:comment])
    render :new unless @comment.valid?
  end

  def create
    @comment = @doc.comments.build(params[:comment])

    return render(:new) if params[:edit_comment]

    @comment.remote_addr = request.remote_addr
    @comment.user_agent = request.user_agent
    @comment.state = (@content.blog_functions[:comment_open] ? GpArticle::Comment::STATE_OPTIONS.first
                                                             : GpArticle::Comment::STATE_OPTIONS.last).last

    if simple_captcha_valid?
      if @comment.save
        redirect_to @doc.public_full_uri
      else
        render :new
      end
    else
      @comment.errors.add(:base, '画像と文字が一致しません。')
      render :confirm
    end
  end
end
