# encoding: utf-8
class Map::Content::Setting < Cms::ContentSetting
  set_config :gp_category_content_category_type_id, name: '汎用カテゴリタイプ',
    options: lambda { GpCategory::Content::CategoryType.where(site_id: Core.site.id).map {|ct| [ct.name, ct.id] } }
  set_config :lat_lng, name: '地図/デフォルト座標',
    comment: '（緯度,経度）'
  set_config :show_images, name: '画像表示',
    options: Map::Content::Marker::IMAGE_STATE_OPTIONS,
    form_type: :radio_buttons
  set_config :default_image, name: '初期画像',
    comment: '（例 /images/sample.jpg ）'
  set_config :marker_order, name: '並び順',
    options: Map::Content::Marker::MARKER_ORDER_OPTIONS
  set_config :title_style, name: "タイトル表示形式",
    form_type: :text, upper_text: "<p><strong>タイトル（リンクなし）：</strong>@title@ <strong>タイトル（リンクあり）：</strong>@title_link@ <strong>サブタイトル：</strong>@subtitle@ <strong>概要：</strong>@summary@ "

  def category_ids
    extra_values[:category_ids] || []
  end

  def categories
    GpCategory::Category.where(id: category_ids)
  end
end
