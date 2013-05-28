# encoding: utf-8

require 'will_paginate/array'

class GpArticle::Admin::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    return error_auth unless @content = GpArticle::Content::Doc.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    @category_types = @content.category_types
    @visible_category_types = @content.visible_category_types
    @recognition_type = @content.setting_value(:recognition_type)
  end

  def index
    if params[:options]
      if params[:category_id]
        if (category = GpCategory::Category.find_by_id(params[:category_id]))
          @items = category.docs
        else
          @items = []
        end
      else
        @items = @content.docs
      end
      render 'index_options', :layout => false
      return
    end

    criteria = params[:criteria] || {}

    if %w!editable recognizable publishable!.include?(params[:target])
      search_params = {}
      search_params[:s_id] = criteria[:id] if criteria[:id].present?
      search_params[:s_title] = criteria[:title] if criteria[:title].present?
      search_params[:s_affiliation_name] = criteria[:group] if criteria[:group].present?
    end

    case params[:target]
    when 'editable'
      item = GpArticle::Doc.new.editable
      item.and :content_id, @content.id
      item.search search_params
      item.page params[:page], params[:limit]
      item.order params[:sort], 'updated_at DESC'
      @items = item.find(:all)
    when 'recognizable'
      item = GpArticle::Doc.new
      if @content.setting_value(:recognition_type) == 'with_admin' && Core.user.has_auth?(:manager)
        item.join_creator
        item.join_recognition
        cond = Condition.new do |c|
          c.or 'sys_recognitions.user_id', Core.user.id
          c.or 'sys_recognitions.recognizer_ids', 'REGEXP', "(^| )#{Core.user.id}( |$)"
          c.or 'sys_recognitions.info_xml', 'LIKE', '%<admin/>%'
        end
        item.and cond
        item.and "#{item.class.table_name}.state", 'recognize'
      else
        item.recognizable
      end

      item.and :content_id, @content.id
      item.search search_params
      item.page params[:page], params[:limit]
      item.order params[:sort], 'updated_at DESC'
      @items = item.find(:all)
    when 'publishable'
      item = GpArticle::Doc.new.publishable
      item.and :content_id, @content.id
      item.search search_params
      item.page params[:page], params[:limit]
      item.order params[:sort], 'updated_at DESC'
      @items = item.find(:all)
    else
      @items = GpArticle::Doc.find_with_content_and_criteria(@content, criteria).paginate(page: params[:page], per_page: 30)
    end

    _index @items
  end

  def show
    @item = @content.docs.find(params[:id])
    @item.recognition.try(:change_type, @recognition_type)
    _show @item
  end

  def new
    @item = @content.docs.build
    @item.in_inquiry = @item.default_inquiry
  end

  def create
    @item = @content.docs.build(params[:item])
    @item.concept = @content.concept
    commit_state = params.keys.detect {|k| k =~ /^commit_/ }
    @item.change_state_by_commit(commit_state)

    _create(@item) do
      set_categories

      @item.fix_tmp_files(params[:_tmp])
      send_recognition_request_mail(@item) if @item.state_recognize?
      publish_by_update(@item) if @item.state_public?
    end
  end

  def update
    @item = @content.docs.find(params[:id])
    @item.attributes = params[:item]
    commit_state = params.keys.detect {|k| k =~ /^commit_/ }
    @item.change_state_by_commit(commit_state)

    _update(@item) do
      set_categories

      send_recognition_request_mail(@item) if @item.state_recognize?
      publish_by_update(@item) if @item.state_public?
      @item.close unless @item.public? # Don't use "state_public?" here
    end
  end

  def destroy
    @item = @content.docs.find(params[:id])
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
    if params[:categories].is_a?(Hash)
      category_ids = params[:categories].values.flatten.reject{|c| c.blank? }.uniq

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
  end
end
