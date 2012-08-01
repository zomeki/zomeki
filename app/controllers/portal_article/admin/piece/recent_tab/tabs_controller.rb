# encoding: utf-8
class PortalArticle::Admin::Piece::RecentTab::TabsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  #simple_layout
  
  def pre_dispatch
    return error_auth unless @piece = Cms::Piece.find(params[:piece])
    return error_auth unless @piece.editable?
    return error_auth unless @content = @piece.content
    #default_url_options[:piece] = @piece
  end
  
  def index
    @items = PortalArticle::Piece::RecentTabXml.find(:all, @piece, :order => :sort_no)
    _index @items
  end
  
  def show
    @item = PortalArticle::Piece::RecentTabXml.find(params[:id], @piece)
    return error_auth unless @item
    _show @item
  end

  def new
    @item = PortalArticle::Piece::RecentTabXml.new(@piece, {
      :sort_no => 0
    })
  end
  
  def create
    @item = PortalArticle::Piece::RecentTabXml.new(@piece, params[:item])
    _create @item
  end
  
  def update
    @item = PortalArticle::Piece::RecentTabXml.find(params[:id], @piece)
    return error_auth unless @item
    @item.attributes = params[:item]
    _update @item
  end
  
  def destroy
    @item = PortalArticle::Piece::RecentTabXml.find(params[:id], @piece)
    _destroy @item
  end
end
