class CreateAdBannerBanners < ActiveRecord::Migration
  def change
    create_table :ad_banner_banners do |t|
      t.string     :name                # Used in module "Sys::Model::Base::File"
      t.string     :title               # Used in module "Sys::Model::Base::File"
      t.string     :mime_type           # Used in module "Sys::Model::Base::File"
      t.integer    :size                # Used in module "Sys::Model::Base::File"
      t.integer    :image_is            # Used in module "Sys::Model::Base::File"
      t.integer    :image_width         # Used in module "Sys::Model::Base::File"
      t.integer    :image_height        # Used in module "Sys::Model::Base::File"

      t.integer    :unid
      t.references :content

      t.references :group

      t.string     :state

      t.string     :advertiser_name
      t.string     :advertiser_phone
      t.string     :advertiser_email
      t.string     :advertiser_contact
      t.datetime   :published_at
      t.datetime   :closed_at
      t.string     :url
      t.integer    :sort_no
      t.string     :token

      t.timestamps
    end

    add_index :ad_banner_banners, :token, :unique => true
  end
end
