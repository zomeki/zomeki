# encoding: utf-8
class Cms::Admin::Tool::ConvertImportsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.root?
    @item = Tool::ConvertImport.find(params[:id]) if params[:id].present?
    @items = Tool::ConvertImport.order('created_at desc').paginate(page: params[:page], per_page: 10)
  end

  def index
    @item = Tool::ConvertImport.new
    _index @items
  end
  
  def create
    @item = Tool::ConvertImport.new(params[:item])
    if @item.creatable? && @item.save
      @item.import
      redirect_to url_for(:action => :index), :notice => "書き込み処理が終了しました。"
    else
      render :index
    end
  end

  def show
    _show @item
  end

  def destroy
    _destroy @item
  end

  def filename_options
    filenames = Tool::ConvertImport.new(site_url: params[:site_url]).site_filename_options
    if filenames.blank?
      filenames = [['ファイルが見つかりませんでした。', '']]
    else
      filenames = [['', '']] + filenames
    end
    render text: ApplicationController.helpers.options_for_select(filenames), layout: false
  end
end
