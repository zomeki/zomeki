# encoding: utf-8
require 'csv'
class Cms::Admin::Tool::ConvertDocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @item = Tool::ConvertDoc.find(params[:id]) if params[:id].present?
  end

  def index
    @items = Tool::ConvertDoc.search_with_criteria(params[:criteria]).order('updated_at desc').paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    _show @item
  end

  def destroy
    _destroy @item
  end

  def destroy_all
    Tool::ConvertDoc.delete_all
    redirect_to url_for(:action => :index)
  end

  def export
    @items = Tool::ConvertDoc.order('created_at desc')
    @org_node_name = Cms::Node.where(model: 'Organization::Group').first.try(:name)

    csv_string = CSV.generate do |csv|
      csv << [Tool::ConvertDoc.human_attribute_name(:uri_path),
             '移行先組織コンテンツURL',
             Tool::ConvertDoc.human_attribute_name(:doc_public_uri),
             Tool::ConvertDoc.human_attribute_name(:title),
             Tool::ConvertDoc.human_attribute_name(:published_at),
             Tool::ConvertDoc.human_attribute_name(:updated_at)]
      @items.find_each do |item|
        org_uri = "/#{@org_node_name}/#{item.page_group_code}/#{item.doc_name}/"
        csv << [item.source_uri, org_uri, item.doc_public_uri, item.title, item.published_at.try(:strftime, '%Y/%m/%d %H:%M:%S'), item.updated_at.try(:strftime, '%Y/%m/%d %H:%M:%S')]
      end
    end

    send_data csv_string.encode(Encoding::WINDOWS_31J, :invalid => :replace, :undef => :replace),
      type: Rack::Mime.mime_type('.csv'), filename: "export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"
  end
end
