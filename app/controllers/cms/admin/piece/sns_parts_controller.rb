class Cms::Admin::Piece::SnsPartsController < Cms::Admin::Piece::BaseController
  def update
    in_settings = {}
    item_in_settings = (params[:item][:in_settings] || {})
    @piece.class::SETTING_KEYS.each {|k| in_settings[k] = item_in_settings[k] }
    params[:item][:in_settings] = in_settings
    super
  end

  private

  def find_piece
    Cms::Piece::SnsPart.find(params[:id])
  end
end
