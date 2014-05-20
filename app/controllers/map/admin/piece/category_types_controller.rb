class Map::Admin::Piece::CategoryTypesController < Cms::Admin::Piece::BaseController
  def update
    item_in_settings = (params[:item][:in_settings] || {})

    if (ids = params[:category_types]).is_a?(Array)
      category_type_ids = ids.map{|id| id.to_i if id.present? }.compact.uniq
      item_in_settings[:category_type_ids] = YAML.dump(category_type_ids)
    end
    item_in_settings[:target_node_id] = params[:target_node]

    params[:item][:in_settings] = item_in_settings
    super
  end

  private

  def find_piece
    model.new.readable.find(params[:id])
  end
end
