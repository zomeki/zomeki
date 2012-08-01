# encoding: utf-8
class PublicBbs::Public::Node::ThreadsController < Cms::Controller::Public::Base
  include Cms::Lib::OAuth

  before_filter :check_creation_setting, :only => [ :new, :create ]
  before_filter :require_o_auth, :except => [ :index, :show ]
  before_filter :allow_only_owner, :only => [ :edit, :update, :destroy ]

  helper_method :public_threads_uri

  def pre_dispatch
    content = Page.current_node.content
    @content = PublicBbs::Content::Thread.find(content) if content.model == 'PublicBbs::Thread'
    return http_error(404) unless @content

    # 管理側でポータル記事分類を設定してあることが前提
    return http_error(403) unless (@portal_group = @content.portal_group)
  end

  def index
    sort = case params[:sort]
           when 't_d'; 'last_updated_at DESC, updated_at DESC'
           when 'n_d'; 'num_reses DESC, updated_at DESC'
           end

    thread = PublicBbs::Thread.new.public
    thread.and :content_id, @content.id
    thread.page  params[:page], 10
    thread.order sort, 'updated_at DESC'

    select_from_pbr = "(SELECT %s FROM public_bbs_responses AS pbr WHERE pbr.thread_id = public_bbs_threads.id AND pbr.state = 'public')"
    num_reses = select_from_pbr % 'COUNT(pbr.id)'
    last_reses_updated_at = select_from_pbr % 'MAX(pbr.updated_at)'
    thread_updated_at = 'public_bbs_threads.updated_at'
    @threads = thread.find(:all, :select => "public_bbs_threads.*, #{num_reses} AS num_reses, IF(#{last_reses_updated_at} > #{thread_updated_at}, #{last_reses_updated_at}, #{thread_updated_at}) AS last_updated_at")

    return http_error(404) if @threads.current_page > @threads.total_pages
  end

  def show
    o_auth_login if params[:o_auth_login]
    o_auth_logout if params[:o_auth_logout]

    thread = PublicBbs::Thread.new.public_or_preview
    thread.and :content_id, @content.id
    thread.and :id, params[:id]
    return http_error(404) unless @item = thread.find(:first)

    Page.current_item = @item
    Page.title        = @item.title
  end

  def new
    @item = current_o_auth_user.threads.build
  end

  def create
    @item = current_o_auth_user.threads.build(params[:item])
    @item.content      = @content
    @item.portal_group = @content.portal_group
    @item.state        = 'public'
    if @item.save
      @item.fix_tmp_files(params[:_tmp])
      redirect_to @item.public_uri, :notice => '書き込みが完了しました。'
    else
      render :action => :new
    end
  end

  def update
    if @item.update_attributes(params[:item])
      redirect_to @item.public_uri, :notice => '更新が完了しました。'
    else
      render :action => :edit
    end
  end

  def destroy
    if @item.destroy
      redirect_to public_threads_uri, :notice => '削除が完了しました。'
    else
      redirect_to @item.public_uri, :alert => '削除に失敗しました。'
    end
  end

  def o_auth_return_to
    uri = public_threads_uri
    case action_name
    when 'new'; uri.concat('/new')
    when 'edit'; uri.concat("/#{params[:id]}/edit")
    when 'show'; uri.concat("/#{params[:id]}")
    else uri
    end
  end

  protected

  def public_threads_uri
    Page.current_node.public_uri.sub(%r|/$|, '')
  end

  def check_creation_setting
    return http_error(403) unless @content.setting_value(:new_thread_creation) == 'allow'
  end

  def allow_only_owner
    return http_error(403) unless @item = current_o_auth_user.threads.find(params[:id])
  end
end
