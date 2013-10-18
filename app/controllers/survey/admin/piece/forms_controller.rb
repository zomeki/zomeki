class Survey::Admin::Piece::FormsController < Cms::Admin::Piece::BaseController
  def update
    item_in_settings = (params[:item][:in_settings] || {})

    item_in_settings[:target_form_id] = params[:target_form]
    item_in_settings[:upper_text] = params[:upper_text]
    item_in_settings[:lower_text] = params[:lower_text]

    params[:item][:in_settings] = item_in_settings
    super
  end
end
