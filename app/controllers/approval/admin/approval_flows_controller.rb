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
    _create(@item) do
      set_approvals
    end
  end

  def update
    @item = @content.approval_flows.find(params[:id])
    @item.attributes = params[:item]
    _update(@item) do
      set_approvals
    end
  end

  def destroy
    @item = @content.approval_flows.find(params[:id])
    _destroy @item
  end

  private

  def set_approvals
    return unless params[:approvals].is_a?(Hash)

    indexes = params[:approvals].keys
    @item.approvals.each{|a| a.destroy unless indexes.include?(a.index.to_s) }

    params[:approvals].each do |key, value|
      next unless value.is_a?(Array)
      approval = @item.approvals.find_by_index(key) || @item.approvals.create(index: key, approval_type: params[:approval_types][key])
      approval.approval_type = params[:approval_types][key]
      approval.save! if approval.changed?
      approval.assignments.destroy_all
      value.each_with_index do |uids, ogid|
        uids.split(",").each do |uid|
          approval.assignments.create(user_id: uid, or_group_id: ogid)
        end
      end
    end
  end
end
