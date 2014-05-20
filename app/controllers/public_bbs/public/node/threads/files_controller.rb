# encoding: utf-8
class PublicBbs::Public::Node::Threads::FilesController < Cms::Controller::Public::Base
  include Cms::Lib::OAuth

  layout 'public/files'

  skip_filter :render_public_layout

  before_filter :require_o_auth, :except => [ :download ]

  helper_method :public_files_uri,
                :public_file_contents_uri

  def pre_dispatch
    thread_id = params[:node_thread_id]
    @tmp_unid = (thread_id.try(:size) == 32) ? thread_id : nil
    unless @tmp_unid
      @thread = PublicBbs::Thread.find(thread_id)
    end

    content = Page.current_node.content
    @content = PublicBbs::Content::Thread.find(content) if content.model == 'PublicBbs::Thread'
    return http_error(404) unless @content
  end

  def index
    @item = Sys::File.new
    if @tmp_unid
      @item.and :tmp_id, @tmp_unid
      @item.and :parent_unid, 'IS', nil
    else
      @item.and :tmp_id, 'IS', nil
      @item.and :parent_unid, @thread.unid
    end
    @item.page  params[:page], params[:limit]
    @item.order params[:sort], :name
    @items = @item.find(:all)
  end

  def show
    @item = Sys::File.new.find(params[:id])
  end

  def create
    item = Sys::File.new(params[:item])
# TODO: システム外ユーザのため管理者を設定（他ユーザの削除を防ぐ）
user = Sys::User.find_by_auth_no(5)
item.in_creator = {'group_id' => user.id, 'user_id' => user.groups.first.id}
    if @tmp_unid
      item.tmp_id      = @tmp_unid
    else
      item.parent_unid = @thread.unid
    end

    item.allowed_type = @content.setting_value(:allowed_attachment_type)
    if item.save
      redirect_to public_files_uri, :notice => '登録が完了しました。'
    else
      redirect_to public_files_uri, :alert => '登録に失敗しました。'
    end
  end

  def edit
    @item = Sys::File.new.find(params[:id])
  end

  def update
    item = Sys::File.new.find(params[:id])
    item.attributes   = params[:item]
    item.allowed_type = @content.setting_value(:allowed_attachment_type)
    item.skip_upload
    if item.save
      redirect_to public_files_uri, :notice => '更新が完了しました。'
    else
      redirect_to public_files_uri, :alert => '更新に失敗しました。'
    end
  end

  def destroy
    item = Sys::File.new.find(params[:id])
    if item.destroy
      redirect_to public_files_uri, :notice => '削除が完了しました。'
    else
      redirect_to public_files_uri, :alert => '削除に失敗しました。'
    end
  end

  def download
    item = Sys::File.new
    if @tmp_unid
      item.and :tmp_id, @tmp_unid
      item.and :parent_unid, 'IS', nil
    else
      item.and :tmp_id, 'IS', nil
      item.and :parent_unid, @thread.unid
    end

    if params[:id]
      item.and :id, params[:id]
    elsif params[:file] && params[:format]
      item.and :name, "#{params[:file]}.#{params[:format]}"
    end
    return http_error(404) unless @file = item.find(:first)

    send_file @file.upload_path, :type => @file.mime_type, :filename => @file.name, :disposition => 'attachment'
  end

  protected

  def public_files_uri
    if @tmp_unid
      "#{@content.thread_node.public_uri}#{@tmp_unid}/files"
    else
      "#{@content.thread_node.public_uri}#{@thread.id}/files"
    end
  end

  def public_file_contents_uri
    if @tmp_unid
      "#{@content.thread_node.public_uri}#{@tmp_unid}/file_contents"
    else
      "#{@content.thread_node.public_uri}#{@thread.id}/file_contents"
    end
  end
end
