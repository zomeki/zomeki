class GpArticle::Public::Node::CommentsController < Cms::Controller::Public::Base
  include SimpleCaptcha::ControllerHelpers

  def pre_dispatch
    if (org_content = Page.current_node.content).kind_of?(Organization::Content::Group)
      settings = GpArticle::Content::Setting.arel_table
      doc_contents = GpArticle::Content::Doc.joins(:settings)
                                            .where(settings[:name].eq('organization_content_group_id').and(settings[:value].eq(org_content.id)))
                                            .where(site_id: org_content.site.id)
      doc_content_ids = doc_contents.map{|d| d.id if d.under_group? }.compact
#TODO: Revert flatted groups
#      if (sys_group = org_content.find_group_by_path_from_root(params[:group_names]).try(:sys_group))
      if (sys_group = org_content.groups.where(name: params[:group_names]).first.try(:sys_group))
        creators = Sys::Creator.arel_table
        docs = GpArticle::Doc.joins(:creator).where(creators[:group_id].eq(sys_group.id))
                             .mobile(Page.mobile?).public
                             .where(content_id: doc_content_ids, name: params[:name])
        if docs.count.zero?
          return http_error(404)
        else
          @content = doc_contents.first
        end
      else
        return http_error(404)
      end
    else
      @content = GpArticle::Content::Doc.find_by_id(Page.current_node.content.id)
    end

    return http_error(404) unless @content

    return http_error(404) unless @content.blog_functions[:comment]

    @doc = @content.public_docs.find_by_name(params[:name])
    return http_error(404) unless @doc

    @confirmation_required = false
  end

  def new
    @comment = @doc.comments.build
    render :new_mobile if Page.mobile?
  end

  def confirm
    if @confirmation_required
      @comment = @doc.comments.build(params[:comment])
      render :new unless @comment.valid?
    else
      create
    end
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
        CommonMailer.commented_notification(@comment).deliver if @content.blog_functions[:comment_notification_mail]
        redirect_to @doc.public_full_uri
      else
        render :new
      end
    else
      @comment.errors.add(:base, '画像と文字が一致しません。')
      if @confirmation_required
        render :confirm
      else
        render :new
      end
    end
  end
end
