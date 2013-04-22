class CreateAdBannerBanners < ActiveRecord::Migration
  def change
    create_table :ad_banner_banners do |t|
      t.string     :name                # Used in module "Sys::Model::Base::File"
      t.string     :title               # Used in module "Sys::Model::Base::File"

      t.references :content

      t.string     :state

      t.string     :advertiser
      t.datetime   :published_at
      t.datetime   :closed_at

      t.timestamps
    end
  end
end
