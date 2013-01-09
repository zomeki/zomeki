class GpCategory::Admin::Piece::CategoryTypesController < Cms::Admin::Piece::BaseController
  def edit
    @item = model.find(params[:id])
    return error_auth unless @item.readable?

    unless @item.setting_value(:layer)
      in_settings = @item.in_settings
      in_settings['layer'] = @item.class::LAYER_OPTIONS.first.last
      @item.in_settings = in_settings
    end

    _show @item
  end
end
