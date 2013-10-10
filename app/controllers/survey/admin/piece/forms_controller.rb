class Survey::Admin::Piece::FormsController < Cms::Admin::Piece::BaseController
  def update
    item_in_settings = (params[:item][:in_settings] || {})

    item_in_settings[:target_form_id] = params[:target_form]

    params[:item][:in_settings] = item_in_settings
    super
  end
end
