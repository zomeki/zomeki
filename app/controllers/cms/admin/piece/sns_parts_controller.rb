class Cms::Admin::Piece::SnsPartsController < Cms::Admin::Piece::BaseController
  def pre_dispatch_piece
    result = super
    @piece = Cms::Piece::SnsPart.find(@piece)
    result
  end

  def update
    in_settings = {}
    item_in_settings = (params[:item][:in_settings] || {})
    @piece.class::SETTING_KEYS.each {|k| in_settings[k] = item_in_settings[k] }
    params[:item][:in_settings] = in_settings
    super
  end
end
