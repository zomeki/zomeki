# encoding: utf-8
class PublicBbs::Public::Node::ResponsesController < Cms::Controller::Public::Base
  include Cms::Lib::OAuth

  before_filter :get_thread # 必ず最初
  before_filter :check_creation_setting, :only => [ :new, :create ]
  before_filter :require_o_auth, :except => [ :index, :show ]
  before_filter :allow_only_owner, :only => [ :edit, :update, :destroy ]

  def pre_dispatch
    content = Page.current_node.content
    @content = PublicBbs::Content::Thread.find(content) if content.model == 'PublicBbs::Thread'
    return http_error(404) unless @content
  end

  def index
    redirect_to @thread.public_uri
  end

  def show
    redirect_to @thread.public_uri
  end

  def new
    @item = @thread.responses.build
  end

  def create
    @item = @thread.responses.build(params[:item])
    @item.content = @content
    @item.state = 'public'
    @item.user = current_o_auth_user
    if @item.save
      @item.fix_tmp_files(params[:_tmp])
      redirect_to @thread.public_uri, :notice => '書き込みが完了しました。'
    else
      render :action => :new
    end
  end

  def update
    if @item.update_attributes(params[:item])
      redirect_to @thread.public_uri, :notice => '更新が完了しました。'
    else
      render :action => :edit
    end
  end

  def destroy
    if @item.destroy
      redirect_to @thread.public_uri, :notice => '削除が完了しました。'
    else
      redirect_to @thread.public_uri, :alert => '削除に失敗しました。'
    end
  end

  def o_auth_return_to
    "#{@thread.public_responses_uri}/#{action_name}"
  end

  protected

  def check_creation_setting
    return http_error(403) unless @thread.res_creation == 'allow'
  end

  def allow_only_owner
    return http_error(403) unless (@item = @thread.responses.find(params[:id])).user == current_o_auth_user
  end

  def get_thread
    thread = PublicBbs::Thread.new.public_or_preview
    thread.and :content_id, @content.id
    thread.and :id, params[:node_thread_id]
    return http_error(404) unless @thread = thread.find(:first)
  end
end
