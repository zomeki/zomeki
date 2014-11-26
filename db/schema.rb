# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20141126052218) do

  create_table "ad_banner_banners", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "mime_type"
    t.integer  "size"
    t.integer  "image_is"
    t.integer  "image_width"
    t.integer  "image_height"
    t.integer  "unid"
    t.integer  "content_id"
    t.integer  "group_id"
    t.string   "state"
    t.string   "advertiser_name"
    t.string   "advertiser_phone"
    t.string   "advertiser_email"
    t.string   "advertiser_contact"
    t.datetime "published_at"
    t.datetime "closed_at"
    t.string   "url"
    t.integer  "sort_no"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ad_banner_banners", ["token"], :name => "index_ad_banner_banners_on_token", :unique => true

  create_table "ad_banner_clicks", :force => true do |t|
    t.integer  "banner_id"
    t.string   "referer"
    t.string   "remote_addr"
    t.string   "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ad_banner_groups", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "name"
    t.string   "title"
    t.integer  "sort_no"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "approval_approval_flows", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "title"
    t.integer  "group_id"
    t.integer  "sort_no"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "approval_approval_request_histories", :force => true do |t|
    t.integer  "request_id"
    t.integer  "user_id"
    t.string   "reason"
    t.text     "comment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "approval_approval_request_histories", ["request_id"], :name => "index_approval_approval_request_histories_on_request_id"
  add_index "approval_approval_request_histories", ["user_id"], :name => "index_approval_approval_request_histories_on_user_id"

  create_table "approval_approval_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "approval_flow_id"
    t.integer  "approvable_id"
    t.string   "approvable_type"
    t.integer  "current_index"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "approval_approvals", :force => true do |t|
    t.integer  "approval_flow_id"
    t.integer  "index"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "approval_assignments", :force => true do |t|
    t.integer  "assignable_id"
    t.string   "assignable_type"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.datetime "approved_at"
    t.integer  "or_group_id"
  end

  add_index "approval_assignments", ["assignable_type", "assignable_id"], :name => "index_approval_assignments_on_assignable_type_and_assignable_id"
  add_index "approval_assignments", ["user_id"], :name => "index_approval_assignments_on_user_id"

  create_table "article_areas", :force => true do |t|
    t.integer  "unid"
    t.integer  "parent_id",                :null => false
    t.integer  "concept_id"
    t.integer  "content_id"
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",                 :null => false
    t.integer  "sort_no"
    t.integer  "layout_id"
    t.string   "name"
    t.text     "title"
    t.text     "zip_code"
    t.text     "address"
    t.text     "tel"
    t.text     "site_uri"
  end

  create_table "article_attributes", :force => true do |t|
    t.integer  "unid"
    t.integer  "concept_id"
    t.integer  "content_id"
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no"
    t.integer  "layout_id"
    t.string   "name"
    t.text     "title"
  end

  create_table "article_categories", :force => true do |t|
    t.integer  "unid"
    t.integer  "parent_id",                :null => false
    t.integer  "concept_id"
    t.integer  "content_id"
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",                 :null => false
    t.integer  "sort_no"
    t.integer  "layout_id"
    t.string   "name"
    t.text     "title"
  end

  create_table "article_docs", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state",         :limit => 15
    t.string   "agent_state",   :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "language_id"
    t.string   "category_ids"
    t.string   "attribute_ids"
    t.string   "area_ids"
    t.string   "rel_doc_ids"
    t.text     "notice_state"
    t.text     "recent_state"
    t.text     "list_state"
    t.text     "event_state"
    t.date     "event_date"
    t.string   "name"
    t.text     "title"
    t.text     "head",          :limit => 2147483647
    t.text     "body",          :limit => 2147483647
    t.text     "mobile_title"
    t.text     "mobile_body",   :limit => 2147483647
  end

  add_index "article_docs", ["content_id", "published_at", "event_date"], :name => "content_id"

  create_table "article_tags", :force => true do |t|
    t.integer  "unid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "word"
  end

  create_table "bbs_items", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "thread_id"
    t.integer  "content_id"
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "email"
    t.string   "uri"
    t.text     "title"
    t.text     "body",       :limit => 2147483647
    t.string   "password",   :limit => 15
    t.string   "ipaddr"
    t.string   "user_agent"
  end

  create_table "calendar_events", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state",        :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.date     "event_date"
    t.string   "event_uri"
    t.text     "title"
    t.text     "body",         :limit => 2147483647
  end

  add_index "calendar_events", ["content_id", "published_at", "event_date"], :name => "content_id"

  create_table "cms_concepts", :force => true do |t|
    t.integer  "unid"
    t.integer  "parent_id"
    t.integer  "site_id"
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",                 :null => false
    t.integer  "sort_no"
    t.string   "name"
  end

  add_index "cms_concepts", ["parent_id", "state", "sort_no"], :name => "parent_id"

  create_table "cms_content_settings", :force => true do |t|
    t.integer  "content_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "value"
    t.integer  "sort_no"
    t.text     "extra_value"
  end

  add_index "cms_content_settings", ["content_id"], :name => "content_id"

  create_table "cms_contents", :force => true do |t|
    t.integer  "unid"
    t.integer  "site_id",                              :null => false
    t.integer  "concept_id"
    t.string   "state",          :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "model"
    t.string   "name"
    t.text     "xml_properties", :limit => 2147483647
    t.string   "note"
    t.string   "code"
  end

  create_table "cms_data_file_nodes", :force => true do |t|
    t.integer  "unid"
    t.integer  "site_id"
    t.integer  "concept_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "title"
  end

  add_index "cms_data_file_nodes", ["concept_id", "name"], :name => "concept_id"

  create_table "cms_data_files", :force => true do |t|
    t.integer  "unid"
    t.integer  "site_id"
    t.integer  "concept_id"
    t.integer  "node_id"
    t.string   "state",        :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.string   "name"
    t.text     "title"
    t.text     "mime_type"
    t.integer  "size"
    t.integer  "image_is"
    t.integer  "image_width"
    t.integer  "image_height"
  end

  add_index "cms_data_files", ["concept_id", "node_id", "name"], :name => "concept_id"

  create_table "cms_data_texts", :force => true do |t|
    t.integer  "unid"
    t.integer  "site_id"
    t.integer  "concept_id"
    t.string   "state",        :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.string   "name"
    t.text     "title"
    t.text     "body",         :limit => 2147483647
  end

  create_table "cms_feed_entries", :force => true do |t|
    t.integer  "feed_id"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "entry_id"
    t.datetime "entry_updated"
    t.date     "event_date"
    t.text     "title"
    t.text     "summary",        :limit => 2147483647
    t.text     "link_alternate"
    t.text     "link_enclosure"
    t.text     "categories"
    t.text     "author_name"
    t.string   "author_email"
    t.text     "author_uri"
  end

  add_index "cms_feed_entries", ["feed_id", "content_id", "entry_updated"], :name => "feed_id"

  create_table "cms_feeds", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",           :null => false
    t.text     "uri"
    t.text     "title"
    t.string   "feed_id"
    t.string   "feed_type"
    t.datetime "feed_updated"
    t.text     "feed_title"
    t.text     "link_alternate"
    t.integer  "entry_count"
  end

  create_table "cms_inquiries", :force => true do |t|
    t.integer  "parent_unid"
    t.string   "state",       :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.text     "charge"
    t.text     "tel"
    t.text     "fax"
    t.text     "email"
  end

  add_index "cms_inquiries", ["parent_unid"], :name => "index_cms_inquiries_on_parent_unid"

  create_table "cms_kana_dictionaries", :force => true do |t|
    t.integer  "unid"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "body",       :limit => 2147483647
    t.text     "mecab_csv",  :limit => 2147483647
  end

  create_table "cms_layouts", :force => true do |t|
    t.integer  "unid"
    t.integer  "concept_id"
    t.integer  "template_id"
    t.integer  "site_id",                                      :null => false
    t.string   "state",                  :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.string   "name"
    t.text     "title"
    t.text     "head",                   :limit => 2147483647
    t.text     "body",                   :limit => 2147483647
    t.text     "stylesheet",             :limit => 2147483647
    t.text     "mobile_head"
    t.text     "mobile_body",            :limit => 2147483647
    t.text     "mobile_stylesheet",      :limit => 2147483647
    t.text     "smart_phone_head"
    t.text     "smart_phone_body",       :limit => 2147483647
    t.text     "smart_phone_stylesheet", :limit => 2147483647
  end

  create_table "cms_link_check_logs", :force => true do |t|
    t.integer  "link_check_id"
    t.integer  "link_checkable_id"
    t.string   "link_checkable_type"
    t.boolean  "checked"
    t.string   "title"
    t.string   "body"
    t.string   "url"
    t.integer  "status"
    t.string   "reason"
    t.boolean  "result"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "cms_link_checks", :force => true do |t|
    t.boolean  "in_progress"
    t.boolean  "checked"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "cms_map_markers", :force => true do |t|
    t.integer  "map_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no"
    t.string   "name"
    t.string   "lat"
    t.string   "lng"
  end

  add_index "cms_map_markers", ["map_id"], :name => "map_id"

  create_table "cms_maps", :force => true do |t|
    t.integer  "unid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "title"
    t.text     "map_lat"
    t.text     "map_lng"
    t.text     "map_zoom"
    t.text     "point1_name"
    t.text     "point1_lat"
    t.text     "point1_lng"
    t.text     "point2_name"
    t.text     "point2_lat"
    t.text     "point2_lng"
    t.text     "point3_name"
    t.text     "point3_lat"
    t.text     "point3_lng"
    t.text     "point4_name"
    t.text     "point4_lat"
    t.text     "point4_lng"
    t.text     "point5_name"
    t.text     "point5_lat"
    t.text     "point5_lng"
  end

  create_table "cms_nodes", :force => true do |t|
    t.integer  "unid"
    t.integer  "concept_id"
    t.integer  "site_id"
    t.string   "state",           :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "parent_id"
    t.integer  "route_id"
    t.integer  "content_id"
    t.string   "model"
    t.integer  "directory"
    t.integer  "layout_id"
    t.string   "name"
    t.text     "title"
    t.text     "body",            :limit => 2147483647
    t.text     "mobile_title"
    t.text     "mobile_body",     :limit => 2147483647
    t.string   "sitemap_state"
    t.integer  "sitemap_sort_no"
  end

  add_index "cms_nodes", ["parent_id", "name"], :name => "parent_id"

  create_table "cms_o_auth_users", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nickname"
    t.string   "url"
  end

  create_table "cms_piece_link_items", :force => true do |t|
    t.integer  "piece_id",                 :null => false
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "body"
    t.string   "uri"
    t.integer  "sort_no"
    t.string   "target"
  end

  add_index "cms_piece_link_items", ["piece_id"], :name => "piece_id"

  create_table "cms_piece_settings", :force => true do |t|
    t.integer  "piece_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "value"
    t.integer  "sort_no"
    t.text     "extra_value"
  end

  add_index "cms_piece_settings", ["piece_id"], :name => "piece_id"

  create_table "cms_pieces", :force => true do |t|
    t.integer  "unid"
    t.integer  "concept_id"
    t.integer  "site_id",                              :null => false
    t.string   "state",          :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "content_id"
    t.string   "model"
    t.string   "name"
    t.text     "title"
    t.string   "view_title"
    t.text     "head",           :limit => 2147483647
    t.text     "body",           :limit => 2147483647
    t.text     "xml_properties", :limit => 2147483647
    t.text     "etcetera",       :limit => 16777215
  end

  add_index "cms_pieces", ["concept_id", "name", "state"], :name => "concept_id"

  create_table "cms_site_basic_auth_users", :force => true do |t|
    t.integer  "unid"
    t.string   "state"
    t.integer  "site_id"
    t.string   "name"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_site_belongings", :force => true do |t|
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
  end

  add_index "cms_site_belongings", ["group_id"], :name => "index_cms_site_belongings_on_group_id"
  add_index "cms_site_belongings", ["site_id"], :name => "index_cms_site_belongings_on_site_id"

  create_table "cms_site_settings", :force => true do |t|
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       :limit => 32
    t.text     "value"
    t.integer  "sort_no"
  end

  add_index "cms_site_settings", ["site_id", "name"], :name => "concept_id"

  create_table "cms_sites", :force => true do |t|
    t.integer  "unid"
    t.string   "state",                :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "full_uri"
    t.string   "mobile_full_uri"
    t.integer  "node_id"
    t.text     "related_site"
    t.string   "map_key"
    t.integer  "portal_group_id"
    t.integer  "portal_category_ids"
    t.integer  "portal_business_ids"
    t.integer  "portal_attribute_ids"
    t.integer  "portal_area_ids"
    t.text     "body"
    t.integer  "site_image_id"
    t.string   "portal_group_state"
  end

  create_table "cms_talk_tasks", :force => true do |t|
    t.integer  "unid"
    t.string   "dependent",    :limit => 64
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "path"
    t.string   "content_hash"
  end

  add_index "cms_talk_tasks", ["unid", "dependent"], :name => "unid"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "enquete_answer_columns", :force => true do |t|
    t.integer "answer_id"
    t.integer "form_id"
    t.integer "column_id"
    t.text    "value",     :limit => 2147483647
  end

  add_index "enquete_answer_columns", ["answer_id", "form_id", "column_id"], :name => "answer_id"

  create_table "enquete_answers", :force => true do |t|
    t.integer  "content_id"
    t.integer  "form_id"
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.string   "ipaddr"
    t.text     "user_agent"
  end

  add_index "enquete_answers", ["content_id", "form_id"], :name => "content_id"

  create_table "enquete_form_columns", :force => true do |t|
    t.integer  "unid"
    t.integer  "form_id"
    t.string   "state",        :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no"
    t.text     "name"
    t.text     "body"
    t.string   "column_type"
    t.string   "column_style"
    t.integer  "required"
    t.text     "options",      :limit => 2147483647
  end

  add_index "enquete_form_columns", ["form_id", "sort_no"], :name => "form_id"

  create_table "enquete_forms", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no"
    t.text     "name"
    t.text     "body",       :limit => 2147483647
    t.text     "summary"
    t.text     "sent_body",  :limit => 2147483647
  end

  add_index "enquete_forms", ["content_id", "sort_no"], :name => "content_id"

  create_table "gnav_category_sets", :force => true do |t|
    t.integer "menu_item_id"
    t.integer "category_id"
    t.string  "layer"
  end

  add_index "gnav_category_sets", ["category_id"], :name => "index_gnav_category_sets_on_category_id"
  add_index "gnav_category_sets", ["menu_item_id"], :name => "index_gnav_category_sets_on_menu_item_id"

  create_table "gnav_menu_items", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.integer  "concept_id"
    t.string   "state"
    t.string   "name"
    t.string   "title"
    t.integer  "sort_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "layout_id"
    t.string   "sitemap_state"
  end

  add_index "gnav_menu_items", ["concept_id"], :name => "index_gnav_menu_items_on_concept_id"
  add_index "gnav_menu_items", ["content_id"], :name => "index_gnav_menu_items_on_content_id"
  add_index "gnav_menu_items", ["layout_id"], :name => "index_gnav_menu_items_on_layout_id"

  create_table "gp_article_comments", :force => true do |t|
    t.integer  "doc_id"
    t.string   "state"
    t.string   "author_name"
    t.string   "author_email"
    t.string   "author_url"
    t.string   "remote_addr"
    t.string   "user_agent"
    t.text     "body"
    t.datetime "posted_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "gp_article_comments", ["doc_id"], :name => "index_gp_article_comments_on_doc_id"

  create_table "gp_article_docs", :force => true do |t|
    t.integer  "unid"
    t.integer  "concept_id"
    t.integer  "content_id"
    t.string   "title"
    t.text     "body",                       :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "href"
    t.string   "target"
    t.text     "subtitle"
    t.text     "summary"
    t.string   "name"
    t.datetime "published_at"
    t.datetime "recognized_at"
    t.string   "state"
    t.string   "event_state"
    t.text     "raw_tags"
    t.string   "mobile_title"
    t.text     "mobile_body"
    t.boolean  "terminal_pc_or_smart_phone"
    t.boolean  "terminal_mobile"
    t.string   "rel_doc_ids"
    t.datetime "display_published_at"
    t.datetime "display_updated_at"
    t.date     "event_started_on"
    t.date     "event_ended_on"
    t.string   "marker_state"
    t.text     "meta_description"
    t.string   "meta_keywords"
    t.string   "list_image"
    t.integer  "prev_edition_id"
    t.string   "og_type"
    t.string   "og_title"
    t.text     "og_description"
    t.string   "og_image"
    t.integer  "template_id"
    t.text     "template_values"
    t.string   "share_to_sns_with"
    t.text     "body_more"
    t.string   "body_more_link_text"
    t.boolean  "feature_1"
    t.boolean  "feature_2"
    t.string   "filename_base"
    t.integer  "marker_icon_category_id"
    t.boolean  "keep_display_updated_at"
  end

  add_index "gp_article_docs", ["concept_id"], :name => "index_gp_article_docs_on_concept_id"
  add_index "gp_article_docs", ["content_id"], :name => "index_gp_article_docs_on_content_id"

  create_table "gp_article_docs_tag_tags", :id => false, :force => true do |t|
    t.integer "doc_id"
    t.integer "tag_id"
  end

  create_table "gp_article_holds", :force => true do |t|
    t.integer  "holdable_id"
    t.string   "holdable_type"
    t.integer  "user_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "gp_article_links", :force => true do |t|
    t.integer  "doc_id"
    t.string   "body"
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "gp_calendar_events", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state"
    t.date     "started_on"
    t.date     "ended_on"
    t.string   "name"
    t.string   "title"
    t.string   "href"
    t.string   "target"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "gp_calendar_events_gp_category_categories", :id => false, :force => true do |t|
    t.integer "event_id"
    t.integer "category_id"
  end

  create_table "gp_calendar_holidays", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state"
    t.string   "title"
    t.date     "date"
    t.text     "description"
    t.string   "kind"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.boolean  "repeat"
  end

  create_table "gp_category_categories", :force => true do |t|
    t.integer  "unid"
    t.integer  "concept_id"
    t.integer  "layout_id"
    t.integer  "category_type_id"
    t.integer  "parent_id"
    t.string   "state"
    t.string   "name"
    t.string   "title"
    t.integer  "level_no"
    t.integer  "sort_no"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group_code"
    t.string   "sitemap_state"
    t.string   "docs_order"
    t.integer  "template_id"
    t.integer  "children_count",   :default => 0, :null => false
  end

  add_index "gp_category_categories", ["category_type_id"], :name => "index_gp_category_categories_on_category_type_id"
  add_index "gp_category_categories", ["concept_id"], :name => "index_gp_category_categories_on_concept_id"
  add_index "gp_category_categories", ["layout_id"], :name => "index_gp_category_categories_on_layout_id"
  add_index "gp_category_categories", ["parent_id"], :name => "index_gp_category_categories_on_parent_id"

  create_table "gp_category_categorizations", :force => true do |t|
    t.integer  "categorizable_id"
    t.string   "categorizable_type"
    t.integer  "category_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "sort_no"
    t.string   "categorized_as"
  end

  create_table "gp_category_category_types", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.integer  "concept_id"
    t.integer  "layout_id"
    t.string   "state"
    t.string   "name"
    t.string   "title"
    t.integer  "sort_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sitemap_state"
    t.string   "docs_order"
    t.integer  "template_id"
    t.integer  "internal_category_type_id"
  end

  add_index "gp_category_category_types", ["concept_id"], :name => "index_gp_category_category_types_on_concept_id"
  add_index "gp_category_category_types", ["content_id"], :name => "index_gp_category_category_types_on_content_id"
  add_index "gp_category_category_types", ["layout_id"], :name => "index_gp_category_category_types_on_layout_id"

  create_table "gp_category_publishers", :force => true do |t|
    t.integer  "category_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "gp_category_publishers", ["category_id"], :name => "index_gp_category_publishers_on_category_id"

  create_table "gp_category_template_modules", :force => true do |t|
    t.integer  "content_id"
    t.string   "name"
    t.string   "title"
    t.string   "module_type"
    t.string   "module_type_feature"
    t.string   "wrapper_tag"
    t.text     "doc_style"
    t.integer  "num_docs"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.text     "upper_text"
    t.text     "lower_text"
  end

  add_index "gp_category_template_modules", ["content_id"], :name => "index_gp_category_template_modules_on_content_id"

  create_table "gp_category_templates", :force => true do |t|
    t.integer  "content_id"
    t.string   "name"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "gp_category_templates", ["content_id"], :name => "index_gp_category_templates_on_content_id"

  create_table "gp_template_items", :force => true do |t|
    t.integer  "template_id"
    t.string   "state"
    t.string   "name"
    t.string   "title"
    t.string   "item_type"
    t.text     "item_options"
    t.string   "style_attribute"
    t.integer  "sort_no"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "gp_template_items", ["template_id"], :name => "index_gp_template_items_on_template_id"

  create_table "gp_template_templates", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state"
    t.string   "title"
    t.text     "body"
    t.integer  "sort_no"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "gp_template_templates", ["content_id"], :name => "index_gp_template_templates_on_content_id"

  create_table "laby_docs", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state",        :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.string   "name"
    t.text     "title"
    t.text     "head",         :limit => 2147483647
    t.text     "body",         :limit => 2147483647
  end

  create_table "map_markers", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state"
    t.string   "title"
    t.string   "latitude"
    t.string   "longitude"
    t.text     "window_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "icon_category_id"
  end

  create_table "newsletter_delivery_logs", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state",             :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "doc_id"
    t.string   "letter_type",       :limit => 15
    t.text     "title"
    t.text     "body",              :limit => 2147483647
    t.string   "delivery_state",    :limit => 15
    t.integer  "delivered_count"
    t.integer  "deliverable_count"
    t.integer  "last_member_id"
  end

  add_index "newsletter_delivery_logs", ["content_id", "doc_id", "letter_type"], :name => "content_id"

  create_table "newsletter_docs", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state",          :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "delivery_state", :limit => 15
    t.datetime "delivered_at"
    t.string   "name"
    t.text     "title"
    t.text     "body",           :limit => 2147483647
    t.text     "mobile_title"
    t.text     "mobile_body",    :limit => 2147483647
  end

  add_index "newsletter_docs", ["content_id", "updated_at"], :name => "content_id"

  create_table "newsletter_members", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state",            :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "letter_type",      :limit => 15
    t.text     "email"
    t.integer  "delivered_doc_id"
    t.datetime "delivered_at"
  end

  add_index "newsletter_members", ["content_id", "letter_type", "created_at"], :name => "content_id"

  create_table "newsletter_requests", :force => true do |t|
    t.integer  "content_id"
    t.string   "state",             :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "request_state",     :limit => 15
    t.string   "request_type",      :limit => 15
    t.string   "letter_type",       :limit => 15
    t.text     "subscribe_email"
    t.text     "unsubscribe_email"
    t.text     "token"
  end

  add_index "newsletter_requests", ["content_id", "request_state", "request_type"], :name => "content_id"

  create_table "newsletter_tests", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state",       :limit => 15
    t.string   "agent_state", :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "name"
    t.text     "email"
  end

  create_table "organization_groups", :force => true do |t|
    t.integer  "unid"
    t.integer  "concept_id"
    t.integer  "layout_id"
    t.integer  "content_id"
    t.string   "state"
    t.string   "name"
    t.string   "sys_group_code"
    t.string   "sitemap_state"
    t.string   "docs_order"
    t.integer  "sort_no"
    t.text     "business_outline"
    t.text     "contact_information"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "more_layout_id"
  end

  add_index "organization_groups", ["sys_group_code"], :name => "index_organization_groups_on_sys_group_code"

  create_table "portal_article_categories", :force => true do |t|
    t.integer  "unid"
    t.integer  "parent_id",                :null => false
    t.integer  "concept_id"
    t.integer  "content_id"
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",                 :null => false
    t.integer  "sort_no"
    t.integer  "layout_id"
    t.string   "name"
    t.text     "title"
  end

  create_table "portal_article_docs", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state",                :limit => 15
    t.string   "agent_state",          :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "language_id"
    t.text     "category_ids"
    t.integer  "portal_group_id"
    t.text     "portal_category_ids"
    t.text     "portal_business_ids"
    t.text     "portal_attribute_ids"
    t.text     "portal_area_ids"
    t.string   "rel_doc_ids"
    t.text     "notice_state"
    t.string   "name"
    t.text     "title"
    t.text     "head",                 :limit => 2147483647
    t.text     "body",                 :limit => 2147483647
    t.text     "mobile_title"
    t.text     "mobile_body",          :limit => 2147483647
    t.string   "event_state"
    t.date     "event_date"
    t.string   "portal_group_state"
  end

  create_table "portal_article_tags", :force => true do |t|
    t.integer  "unid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "word"
  end

  create_table "portal_calendar_events", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state",            :limit => 15
    t.date     "event_start_date"
    t.date     "event_end_date"
    t.string   "event_uri",                              :default => ""
    t.string   "title"
    t.text     "body",             :limit => 2147483647
    t.integer  "event_genre_id",                         :default => 0
    t.integer  "event_status_id",                        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "portal_calendar_events", ["content_id", "event_start_date"], :name => "content_id"

  create_table "portal_calendar_genres", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state",      :default => "public"
    t.string   "title",      :default => ""
    t.integer  "sort_no",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portal_calendar_statuses", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state",      :default => "public"
    t.string   "title",      :default => ""
    t.integer  "sort_no",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portal_categories", :force => true do |t|
    t.integer  "unid"
    t.integer  "parent_id",                              :null => false
    t.integer  "content_id"
    t.string   "state",            :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",                               :null => false
    t.integer  "sort_no"
    t.integer  "layout_id"
    t.string   "name"
    t.text     "title"
    t.text     "entry_categories", :limit => 2147483647
  end

  add_index "portal_categories", ["parent_id", "content_id", "state"], :name => "parent_id"

  create_table "portal_group_areas", :force => true do |t|
    t.integer  "unid"
    t.integer  "parent_id",                :null => false
    t.integer  "content_id"
    t.integer  "concept_id"
    t.integer  "site_id"
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",                 :null => false
    t.integer  "sort_no"
    t.integer  "layout_id"
    t.string   "name"
    t.text     "title"
    t.text     "zip_code"
    t.text     "address"
    t.text     "tel"
    t.text     "site_uri"
  end

  create_table "portal_group_attributes", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.integer  "concept_id"
    t.integer  "site_id"
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no"
    t.integer  "layout_id"
    t.string   "name"
    t.text     "title"
  end

  create_table "portal_group_businesses", :force => true do |t|
    t.integer  "unid"
    t.integer  "parent_id",                :null => false
    t.integer  "content_id"
    t.integer  "concept_id"
    t.integer  "site_id"
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",                 :null => false
    t.integer  "sort_no"
    t.integer  "layout_id"
    t.string   "name"
    t.text     "title"
  end

  create_table "portal_group_categories", :force => true do |t|
    t.integer  "unid"
    t.integer  "parent_id",                :null => false
    t.integer  "content_id"
    t.integer  "concept_id"
    t.integer  "site_id"
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",                 :null => false
    t.integer  "sort_no"
    t.integer  "layout_id"
    t.string   "name"
    t.text     "title"
  end

  create_table "public_bbs_categories", :force => true do |t|
    t.integer  "unid"
    t.string   "state"
    t.integer  "concept_id"
    t.integer  "content_id"
    t.integer  "layout_id"
    t.integer  "level_no",   :null => false
    t.integer  "sort_no"
    t.integer  "parent_id"
    t.string   "name"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "public_bbs_categories", ["content_id"], :name => "index_public_bbs_categories_on_content_id"

  create_table "public_bbs_responses", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state"
    t.integer  "thread_id"
    t.integer  "user_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "public_bbs_responses", ["content_id"], :name => "index_public_bbs_responses_on_content_id"
  add_index "public_bbs_responses", ["thread_id"], :name => "index_public_bbs_responses_on_thread_id"
  add_index "public_bbs_responses", ["user_id"], :name => "index_public_bbs_responses_on_user_id"

  create_table "public_bbs_tags", :force => true do |t|
    t.integer  "unid"
    t.string   "name"
    t.text     "word"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public_bbs_threads", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state"
    t.integer  "user_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "category_ids"
    t.text     "portal_category_ids"
    t.integer  "portal_group_id"
    t.text     "portal_business_ids"
    t.text     "portal_attribute_ids"
    t.text     "portal_area_ids"
    t.string   "res_creation"
  end

  add_index "public_bbs_threads", ["content_id"], :name => "index_public_bbs_threads_on_content_id"
  add_index "public_bbs_threads", ["user_id"], :name => "index_public_bbs_threads_on_user_id"

  create_table "rank_categories", :force => true do |t|
    t.integer  "content_id"
    t.string   "page_path"
    t.integer  "category_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "rank_ranks", :force => true do |t|
    t.integer  "content_id"
    t.string   "page_title"
    t.string   "hostname"
    t.string   "page_path"
    t.date     "date"
    t.integer  "pageviews"
    t.integer  "visitors"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "rank_totals", :force => true do |t|
    t.integer  "content_id"
    t.string   "term"
    t.string   "page_title"
    t.string   "hostname"
    t.string   "page_path"
    t.integer  "pageviews"
    t.integer  "visitors"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "simple_captcha_data", ["key"], :name => "idx_key"

  create_table "sns_share_accounts", :force => true do |t|
    t.integer  "content_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "info_nickname"
    t.string   "info_name"
    t.string   "info_image"
    t.string   "info_url"
    t.string   "credential_token"
    t.string   "credential_expires_at"
    t.string   "credential_secret"
    t.text     "facebook_page_options"
    t.string   "facebook_page"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "sns_share_accounts", ["content_id"], :name => "index_sns_share_accounts_on_content_id"

  create_table "sns_share_shares", :force => true do |t|
    t.integer  "sharable_id"
    t.string   "sharable_type"
    t.integer  "account_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "sns_share_shares", ["sharable_type", "sharable_id"], :name => "index_sns_share_shares_on_sharable_type_and_sharable_id"

  create_table "survey_answers", :force => true do |t|
    t.integer  "form_answer_id"
    t.integer  "question_id"
    t.text     "content"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "survey_answers", ["form_answer_id"], :name => "index_survey_answers_on_form_answer_id"
  add_index "survey_answers", ["question_id"], :name => "index_survey_answers_on_question_id"

  create_table "survey_form_answers", :force => true do |t|
    t.integer  "form_id"
    t.string   "answered_url"
    t.string   "remote_addr"
    t.string   "user_agent"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "answered_url_title"
  end

  add_index "survey_form_answers", ["form_id"], :name => "index_survey_form_answers_on_form_id"

  create_table "survey_forms", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.string   "state"
    t.string   "name"
    t.string   "title"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.datetime "opened_at"
    t.datetime "closed_at"
    t.integer  "sort_no"
    t.text     "summary"
    t.text     "description"
    t.text     "receipt"
    t.boolean  "confirmation"
    t.string   "sitemap_state"
    t.string   "index_link"
  end

  add_index "survey_forms", ["content_id"], :name => "index_survey_forms_on_content_id"

  create_table "survey_questions", :force => true do |t|
    t.integer  "form_id"
    t.string   "state"
    t.string   "title"
    t.text     "description"
    t.string   "form_type"
    t.text     "form_options"
    t.boolean  "required"
    t.string   "style_attribute"
    t.integer  "sort_no"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "form_text_max_length"
  end

  add_index "survey_questions", ["form_id"], :name => "index_survey_questions_on_form_id"

  create_table "sys_cache_sweepers", :force => true do |t|
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "model"
    t.text     "uri"
    t.text     "options"
  end

  add_index "sys_cache_sweepers", ["model", "uri"], :name => "model", :length => {"model"=>20, "uri"=>30}

  create_table "sys_closers", :force => true do |t|
    t.integer  "unid"
    t.string   "dependent",      :limit => 64
    t.string   "path"
    t.string   "content_hash"
    t.datetime "published_at"
    t.datetime "republished_at"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "sys_closers", ["unid", "dependent"], :name => "index_sys_closers_on_unid_and_dependent"

  create_table "sys_creators", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
  end

  create_table "sys_editable_groups", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "group_ids"
    t.boolean  "all"
  end

  create_table "sys_files", :force => true do |t|
    t.integer  "unid"
    t.string   "tmp_id"
    t.integer  "parent_unid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "title"
    t.text     "mime_type"
    t.integer  "size"
    t.integer  "image_is"
    t.integer  "image_width"
    t.integer  "image_height"
  end

  add_index "sys_files", ["parent_unid", "name"], :name => "parent_unid"

  create_table "sys_groups", :force => true do |t|
    t.integer  "unid"
    t.string   "state",        :limit => 15
    t.string   "web_state",    :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",                  :null => false
    t.integer  "level_no"
    t.string   "code",                       :null => false
    t.integer  "sort_no"
    t.integer  "layout_id"
    t.integer  "ldap",                       :null => false
    t.string   "ldap_version"
    t.string   "name"
    t.string   "name_en"
    t.string   "tel"
    t.string   "fax"
    t.string   "outline_uri"
    t.string   "email"
    t.string   "address"
    t.string   "note"
    t.string   "tel_attend"
  end

  create_table "sys_languages", :force => true do |t|
    t.string   "state",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no"
    t.string   "name"
    t.text     "title"
  end

  create_table "sys_ldap_synchros", :force => true do |t|
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version",    :limit => 10
    t.string   "entry_type", :limit => 15
    t.string   "code"
    t.integer  "sort_no"
    t.string   "name"
    t.string   "name_en"
    t.string   "email"
  end

  add_index "sys_ldap_synchros", ["version", "parent_id", "entry_type"], :name => "version"

  create_table "sys_maintenances", :force => true do |t|
    t.integer  "unid"
    t.string   "state",        :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.text     "title"
    t.text     "body"
  end

  create_table "sys_messages", :force => true do |t|
    t.integer  "unid"
    t.string   "state",        :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.text     "title"
    t.text     "body"
  end

  create_table "sys_object_privileges", :force => true do |t|
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_unid"
    t.string   "action",     :limit => 15
  end

  add_index "sys_object_privileges", ["item_unid", "action"], :name => "item_unid"

  create_table "sys_operation_logs", :force => true do |t|
    t.integer  "site_id"
    t.integer  "loggable_id"
    t.string   "loggable_type"
    t.integer  "user_id"
    t.string   "operation"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "user_name"
    t.string   "ipaddr"
    t.string   "uri"
    t.string   "action"
    t.string   "item_model"
    t.integer  "item_id"
    t.integer  "item_unid"
    t.string   "item_name"
  end

  create_table "sys_processes", :force => true do |t|
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.datetime "started_at"
    t.datetime "closed_at"
    t.integer  "user_id"
    t.string   "state"
    t.string   "name"
    t.string   "interrupt"
    t.integer  "total"
    t.integer  "current"
    t.integer  "success"
    t.integer  "error"
    t.text     "message",    :limit => 2147483647
  end

  create_table "sys_publishers", :force => true do |t|
    t.integer  "unid"
    t.string   "dependent",    :limit => 64
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "path"
    t.string   "content_hash"
  end

  add_index "sys_publishers", ["unid", "dependent"], :name => "unid"

  create_table "sys_recognitions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "recognizer_ids"
    t.text     "info_xml"
  end

  add_index "sys_recognitions", ["user_id"], :name => "user_id"

  create_table "sys_role_names", :force => true do |t|
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "title"
  end

  create_table "sys_sequences", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "version"
    t.integer  "value"
  end

  add_index "sys_sequences", ["name", "version"], :name => "index_sys_sequences_on_name_and_version", :unique => true

  create_table "sys_settings", :force => true do |t|
    t.string   "name"
    t.text     "value"
    t.integer  "sort_no"
    t.text     "extra_value"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "sys_tasks", :force => true do |t|
    t.integer  "unid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "process_at"
    t.string   "name"
  end

  create_table "sys_temp_texts", :force => true do |t|
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sys_transferable_files", :force => true do |t|
    t.integer  "site_id"
    t.integer  "user_id"
    t.integer  "version"
    t.string   "operation"
    t.string   "file_type"
    t.string   "parent_dir"
    t.string   "path"
    t.string   "destination"
    t.integer  "operator_id"
    t.string   "operator_name"
    t.datetime "operated_at"
    t.integer  "item_id"
    t.integer  "item_unid"
    t.string   "item_model"
    t.string   "item_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "sys_transferable_files", ["user_id", "operator_id"], :name => "index_sys_transferable_files_on_user_id_and_operator_id"

  create_table "sys_transferred_files", :force => true do |t|
    t.integer  "site_id"
    t.integer  "version"
    t.string   "operation"
    t.string   "file_type"
    t.string   "parent_dir"
    t.string   "path"
    t.string   "destination"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "user_id"
    t.integer  "operator_id"
    t.string   "operator_name"
    t.datetime "operated_at"
    t.integer  "item_id"
    t.integer  "item_unid"
    t.string   "item_model"
    t.string   "item_name"
  end

  add_index "sys_transferred_files", ["created_at"], :name => "index_sys_transferred_files_on_created_at"
  add_index "sys_transferred_files", ["operator_id"], :name => "index_sys_transferred_files_on_operator_id"
  add_index "sys_transferred_files", ["user_id"], :name => "index_sys_transferred_files_on_user_id"
  add_index "sys_transferred_files", ["version"], :name => "index_sys_transferred_files_on_version"

  create_table "sys_unid_relations", :force => true do |t|
    t.integer "unid",     :null => false
    t.integer "rel_unid", :null => false
    t.string  "rel_type", :null => false
  end

  add_index "sys_unid_relations", ["rel_unid"], :name => "rel_unid"
  add_index "sys_unid_relations", ["unid"], :name => "unid"

  create_table "sys_unids", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "model",      :null => false
    t.integer  "item_id"
  end

  create_table "sys_users", :force => true do |t|
    t.string   "state",                           :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ldap",                                                             :null => false
    t.string   "ldap_version"
    t.integer  "auth_no",                                                          :null => false
    t.string   "name"
    t.string   "name_en"
    t.string   "account"
    t.string   "password"
    t.string   "email"
    t.text     "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "admin_creatable",                               :default => false
    t.boolean  "site_creatable",                                :default => false
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
  end

  create_table "sys_users_groups", :id => false, :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
  end

  add_index "sys_users_groups", ["user_id", "group_id"], :name => "user_id"

  create_table "sys_users_roles", :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "sys_users_roles", ["user_id", "role_id"], :name => "user_id"

  create_table "tag_tags", :force => true do |t|
    t.integer  "content_id"
    t.text     "word"
    t.datetime "last_tagged_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag_tags", ["content_id"], :name => "index_tag_tags_on_content_id"

  create_table "tool_convert_docs", :force => true do |t|
    t.integer  "content_id"
    t.integer  "docable_id"
    t.string   "docable_type"
    t.text     "doc_name"
    t.text     "doc_public_uri"
    t.text     "site_url"
    t.string   "file_path"
    t.text     "uri_path"
    t.text     "title"
    t.text     "body",            :limit => 2147483647
    t.string   "page_updated_at"
    t.string   "page_group_code"
    t.datetime "published_at"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "tool_convert_docs", ["content_id"], :name => "index_tool_convert_docs_on_content_id"
  add_index "tool_convert_docs", ["docable_id", "docable_type"], :name => "index_tool_convert_docs_on_docable_id_and_docable_type"
  add_index "tool_convert_docs", ["uri_path"], :name => "index_tool_convert_docs_on_uri_path", :length => {"uri_path"=>255}

  create_table "tool_convert_downloads", :force => true do |t|
    t.string   "state"
    t.text     "site_url"
    t.text     "include_dir"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "recursive_level"
    t.string   "remark"
    t.text     "message"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "tool_convert_imports", :force => true do |t|
    t.string   "state"
    t.text     "site_url"
    t.string   "site_filename"
    t.integer  "content_id"
    t.integer  "overwrite"
    t.integer  "keep_filename"
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "message"
    t.integer  "total_num"
    t.integer  "created_num"
    t.integer  "updated_num"
    t.integer  "nonupdated_num"
    t.integer  "skipped_num"
    t.integer  "link_total_num"
    t.integer  "link_processed_num"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "tool_convert_links", :force => true do |t|
    t.integer  "concept_id"
    t.integer  "linkable_id"
    t.string   "linkable_type"
    t.text     "urls"
    t.text     "before_body",   :limit => 2147483647
    t.text     "after_body",    :limit => 2147483647
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "tool_convert_settings", :force => true do |t|
    t.string   "site_url"
    t.text     "title_tag"
    t.text     "body_tag"
    t.text     "updated_at_tag"
    t.text     "updated_at_regexp"
    t.text     "creator_group_from_url_regexp"
    t.integer  "creator_group_relation_type"
    t.text     "creator_group_url_relations"
    t.text     "category_tag"
    t.text     "category_regexp"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "tool_convert_settings", ["site_url"], :name => "index_tool_convert_settings_on_site_url"

  create_table "tool_simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
