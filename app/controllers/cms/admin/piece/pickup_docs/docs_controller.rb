# encoding: utf-8
class Cms::Admin::Piece::PickupDocs::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @piece = Cms::Piece::PickupDoc.find_by_id(params[:piece_pickup_doc_id])
    return error_auth unless @piece.editable?
  end

  def index
    @items =  Cms::Piece::PickupDocXml.find(:all, @piece, :order => :sort_no)
    _index @items
  end

  def show
    @item = Cms::Piece::PickupDocXml.find(params[:id], @piece)
    return error_auth unless @item

    @item.doc_id = @item.doc.id if @item.doc

    _show @item
  end

  def new
    @item = Cms::Piece::PickupDocXml.new(@piece, sort_no: 0)
  end

  def create
    @item = Cms::Piece::PickupDocXml.new(@piece, params[:item])
    set_attributes
    _create @item
  end

  def edit
    @item = Cms::Piece::PickupDocXml.find(params[:id], @piece)
    return error_auth unless @item

    @item.doc_id = @item.doc.id if @item.doc




  end

  def update
    @item = Cms::Piece::PickupDocXml.find(params[:id], @piece)
    return error_auth unless @item
    @item.attributes = params[:item]
    set_attributes
    _update @item
  end

  def destroy
    @item = Cms::Piece::PickupDocXml.find(params[:id], @piece)
    _destroy @item
  end

  def set_attributes
    unless @item.doc_id.blank?
      doc = GpArticle::Doc.find_by_id(@item.doc_id)
      @item.doc_name = doc.name
      @item.name = "#{@item.content_id}_#{doc.name}" if @item.name.blank?
    end
  end
end
