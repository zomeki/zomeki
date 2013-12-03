class SnsShare::Admin::AccountsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = SnsShare::Content::Account.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    @item = @content.accounts.find(params[:id]) if params[:id].present?
  end

  def index
    @items = @content.accounts.paginate(page: params[:page], per_page: 30)
    _index @items
  end
end
