# encoding: utf-8
class Sys::Admin::TransferableFilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Lib::File::Transfer

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    @site = Core.site
    @destination_uri = @site.setting_transfer_dest_domain
  end

  def index
    item = Sys::TransferableFile.new
    item.and :site_id, @site.id
    item.and :user_id, Core.user.id
    item.and :file_type, 'file'
    item.search params
    item.page  params[:page], 200 #params[:limit]
    item.order params[:sort], 'id'
    @items = item.find(:all)

    _index @items
  end

  def refresh
    _refresh
    redirect_to sys_transferable_files_path
  end

  def transfer_all
    success = true
    selected_ids = nil
    if params[:transfer_selected]
      selected_ids = params[:selected_ids] ? params[:selected_ids].keys : [];
      success = false if selected_ids.size == 0
    end
    result = transfer_files(:files => selected_ids, :logging => true, :sites => [@site]) || {:version => nil, :sites => {} }

    infos    = result[:sites][@site.id]
    messages = ""
    infos.each do |info|
      unless info[:success]
        success = false
        messages << " [#{info[:code].to_s}:#{info[:message].to_s}]"
      end
    end

    # refresh
    _refresh

    flash[:notice] = success ? "転送処理が完了しました。（バージョン：#{result[:version].to_s}）" : "転送処理でエラーが発生しました。（バージョン：#{result[:version].to_s}）#{messages}";
    redirect_to sys_transferable_files_path
  end

  def show
    @item = Sys::TransferableFile.new.find(params[:id])
    _show @item
  end

  def new
    return error_auth
  end

  def create
    return error_auth
  end

  def update
    return error_auth
  end

  def destroy
    return error_auth
  end

private
  def _refresh
    Sys::TransferableFile.where(:user_id => Core.user.id).delete_all
    # trial run (rsync)
    transfer_files(:trial => true, :logging => true, :sites => [@site])
  end

end
