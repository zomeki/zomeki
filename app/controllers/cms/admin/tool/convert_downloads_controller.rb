# encoding: utf-8
class Cms::Admin::Tool::ConvertDownloadsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    @item = Tool::ConvertDownload.find(params[:id]) if params[:id].present?
    @items = Tool::ConvertDownload.order('created_at desc').paginate(page: params[:page], per_page: 10)
  end

  def index
    @item = Tool::ConvertDownload.new(params[:item])
    _index @items
  end

  def show
    _show @item
  end

  def create
    @item = Tool::ConvertDownload.new(params[:item])
    if @item.creatable? && @item.save
      @item.download
      redirect_to url_for(:action => :index), :notice => "ダウンロード処理が終了しました。"
    else
      render :index
    end
  end

  def destroy
    _destroy @item
  end
end

