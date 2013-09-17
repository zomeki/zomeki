# encoding: utf-8
class Approval::Admin::ApprovalFlowsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Approval::Content::ApprovalFlow.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @content.approval_flows.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    @item = @content.approval_flows.find(params[:id])
    _show @item
  end

  def new
    @item = @content.approval_flows.build
  end

  def create
    @item = @content.approval_flows.build(params[:item])
    _create @item
  end

  def update
    @item = @content.approval_flows.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = @content.approval_flows.find(params[:id])
    _destroy @item
  end
end
