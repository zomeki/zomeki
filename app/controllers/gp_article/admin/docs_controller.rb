# encoding: utf-8
class GpArticle::Admin::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication
  include Sys::Controller::Scaffold::Recognition

  before_filter :hold_document, :only => [ :edit ]
  before_filter :check_intercepted, :only => [ :update ]

  def pre_dispatch
    return error_auth unless @content = GpArticle::Content::Doc.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset_criteria]

    @category_types = @content.category_types
    @visible_category_types = @content.visible_category_types
    @recognition_type = @content.setting_value(:recognition_type)
    @event_category_types = @content.event_category_types
    @marker_category_types = @content.marker_category_types
    @item = @content.docs.find(params[:id]) if params[:id].present?
  end

  def index
    if params[:options]
      @items = if params[:category_id]
                 if (category = GpCategory::Category.find_by_id(params[:category_id]))
                   category.docs
                 else
                   []
                 end
               else
                 @content.docs
               end
      render 'index_options', :layout => false
      return
    end

    criteria = params[:criteria] || {}

    case params[:target]
    when 'all'
      # No criteria
    when 'draft'
      criteria[:state] = 'draft'
      criteria[:touched_user_id] = Core.user.id
    when 'public'
      criteria[:state] = 'public'
      criteria[:touched_user_id] = Core.user.id
    when 'closed'
      criteria[:state] = 'closed'
      criteria[:touched_user_id] = Core.user.id
    when 'recognizable'
      criteria[:recognizable] = true
      criteria[:state] = 'recognize'
    when 'publishable'
      criteria[:recognizable] = true
      criteria[:state] = 'recognized'
    else
      criteria[:editable] = true
    end

    docs = GpArticle::Doc.arel_table
    @items = GpArticle::Doc.all_with_content_and_criteria(@content, criteria).order(docs[:updated_at].desc).paginate(page: params[:page], per_page: 30)

    _index @items
  end

  def show
    @item.recognition.try(:change_type, @recognition_type)
    _show @item
  end

  def new
    @item = @content.docs.build
    @item.in_inquiry = @item.default_inquiry
  end

  def create
    @item = @content.docs.build(params[:item])

    check_results = @item.check_links_in_body
    @item.ignore_broken_links if params[:ignore_link_check]
    if params[:link_check] || @item.broken_link_exists?
      flash[:link_check_result] = render_to_string(:partial => 'link_check_result', :locals => {results: check_results}).html_safe
      return render(:action => :new) if params[:link_check]
    end

    @item.concept = @content.concept
    commit_state = params.keys.detect {|k| k =~ /^commit_/ }
    @item.change_state_by_commit(commit_state)

    location = ->(d){ edit_gp_article_doc_url(@content, d) } if @item.state_draft?
    _create(@item, location: location) do
      set_categories
      set_event_categories
      set_marker_categories

      @item.fix_tmp_files(params[:_tmp])
      send_recognition_request_mail(@item) if @item.state_recognize?
      publish_by_update(@item) if @item.state_public?
    end
  end

  def edit
    @item.recognition.try(:change_type, @recognition_type)
    _show @item
  end

  def update
    @item.attributes = params[:item]

    check_results = @item.check_links_in_body
    @item.ignore_broken_links if params[:ignore_link_check]
    if params[:link_check] || @item.broken_link_exists?
      flash[:link_check_result] = render_to_string(:partial => 'link_check_result', :locals => {results: check_results}).html_safe
      return render(:action => :edit) if params[:link_check]
    end

    commit_state = params.keys.detect {|k| k =~ /^commit_/ }
    @item.change_state_by_commit(commit_state)

    location = url_for(action: 'edit') if @item.state_draft?
    _update(@item, location: location) do
      set_categories
      set_event_categories
      set_marker_categories

      send_recognition_request_mail(@item) if @item.state_recognize?
      publish_by_update(@item) if @item.state_public?
      @item.close unless @item.public? # Don't use "state_public?" here

      release_document
    end
  end

  def destroy
    _destroy @item
  end

  def recognize(item)
    _recognize(item) do
      if @item.state == 'recognized'
        send_recognition_success_mail(@item)
      elsif @recognition_type == 'with_admin'
        if item.recognition.recognized_all?(false)
          users = Sys::User.find_managers
          send_recognition_request_mail(@item, users)
        end
      end
    end
  end

  def publish_ruby(item)
    uri = item.public_uri
    uri = (uri =~ /\?/) ? uri.gsub(/\?/, 'index.html.r?') : "#{uri}index.html.r"
    path = "#{item.public_path}.r"
    item.publish_page(render_public_as_string(uri, :site => item.content.site), :path => path, :dependent => :ruby)
  end

  def publish(item)
    item.public_uri = "#{item.public_uri}?doc_id=#{item.id}"
    item.update_column(:published_at, Core.now)
    _publish(item) { publish_ruby(item) }
  end

  def publish_by_update(item)
    return unless item.terminal_pc_or_smart_phone
    item.public_uri = "#{item.public_uri}?doc_id=#{item.id}"
    if item.publish(render_public_as_string(item.public_uri))
      publish_ruby(item)
      flash[:notice] = '公開処理が完了しました。'
    else
      flash[:alert] = '公開処理に失敗しました。'
    end
  end

  def duplicate(item)
    if dupe_item = item.duplicate
      flash[:notice] = '複製処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to url_for(:action => :index) }
        format.xml  { head :ok }
      end
    else
      flash[:alert] = '複製処理に失敗しました。'
      respond_to do |format|
        format.html { redirect_to url_for(:action => :show) }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected

  def send_recognition_request_mail(item, users=nil)
    users ||= item.recognizers

    mail_from = Core.user.email

    subject = "#{item.content.name}（#{item.content.site.name}）：承認依頼メール"
    body = <<-EOT
#{Core.user.name}さんより「#{item.title}」についての承認依頼が届きました。
  次の手順により，承認作業を行ってください。

  １．PC用記事のプレビューにより文書を確認
    #{item.preview_uri}
  ２．次のリンクから承認を実施
    #{gp_article_doc_url(content: @content, id: item.id)}
    EOT

    users.each {|user| send_mail(mail_from, user.email, subject, body) }
  end

  def send_recognition_success_mail(item)
    return true unless item.recognition
    return true unless item.recognition.user
    return true if item.recognition.user.email.blank?

    mail_from = Core.user.email
    mail_to = item.recognition.user.email

    subject = "#{item.content.name}（#{item.content.site.name}）：最終承認完了メール"
    body = <<-EOT
「#{item.title}」についての承認が完了しました。
  次のＵＲＬをクリックして公開処理を行ってください。
  #{gp_article_doc_url(content: @content, id: item.id)}
    EOT

    send_mail(mail_from, mail_to, subject, body)
  end

  def set_categories
    category_ids = if params[:categories].is_a?(Hash)
                     params[:categories].values.flatten.map{|c| c.to_i if c.present? }.compact.uniq
                   else
                     []
                   end

    if @category_types.include?(@content.group_category_type)
      if (group_category = @content.group_category_type.categories.find_by_group_code(@item.creator.group.code))
        category_ids |= [group_category.id]
      end
    end

    if @content.default_category && @category_types.include?(@content.default_category_type)
      category_ids |= [@content.default_category.id]
    end

    @item.category_ids = category_ids
  end

  def set_event_categories
    event_category_ids = if params[:event_categories].is_a?(Hash)
                           params[:event_categories].values.flatten.map{|c| c.to_i if c.present? }.compact.uniq
                         else
                           []
                         end
    @item.event_category_ids = event_category_ids
  end

  def set_marker_categories
    marker_category_ids = if params[:marker_categories].is_a?(Hash)
                            params[:marker_categories].values.flatten.map{|c| c.to_i if c.present? }.compact.uniq
                          else
                            []
                          end
    @item.marker_category_ids = marker_category_ids
  end

  def hold_document
    unless (holds = @item.holds).empty?
      holds = holds.each{|h| h.destroy if h.user == Core.user }.reject(&:destroyed?)
      alerts = holds.map do |hold|
          in_editing_from = (hold.updated_at.today? ? I18n.l(hold.updated_at, :format => :short_ja) : I18n.l(hold.updated_at, :format => :default_ja))
          "#{hold.user.group.name}#{hold.user.name}さんが#{in_editing_from}から編集中です。"
        end
      flash[:alert] = "<ul><li>#{alerts.join('</li><li>')}</li></ul>".html_safe
    end
    @item.holds.create(user: Core.user)
  end

  def check_intercepted
    unless @item.holds.detect{|h| h.user == Core.user }
      user = @item.operation_logs.first.user
      flash[:alert] = "#{user.group.name}#{user.name}さんが記事を編集したため、編集内容を反映できません。"
      render :action => :edit
    end
  end

  def release_document
    @item.holds.destroy_all
  end
end
