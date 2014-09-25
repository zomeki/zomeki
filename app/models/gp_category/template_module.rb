class GpCategory::TemplateModule < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  WRAPPER_TAG_OPTIONS = [['li', 'li'], ['article', 'article'], ['section', 'section']]
  MODULE_TYPE_OPTIONS = {'カテゴリ一覧' => [['自カテゴリ以下全て', 'categories_1'],
                                            ['自カテゴリの1階層',  'categories_2'],
                                            ['自カテゴリの2階層',  'categories_3']],
                         '記事一覧' => [['自カテゴリ以下全て',                                             'docs_1'],
                                        ['自カテゴリのみ ',                                                'docs_2'],
                                        ['自カテゴリ以下全て+ネスト（汎用カテゴリタイプの1階層目で分類）', 'docs_3'],
                                        ['自カテゴリのみ+ネスト（汎用カテゴリタイプの1階層目で分類）',     'docs_4'],
                                        ['自カテゴリ以下全て+組織 （グループで分類）',                     'docs_5'],
                                        ['自カテゴリのみ+組織（グループで分類）',                          'docs_6'],
                                        ['自カテゴリ直下のカテゴリ（カテゴリで分類）',                     'docs_7'],
                                        ['自カテゴリ直下のカテゴリ+1階層目カテゴリ表示（カテゴリで分類）', 'docs_8']]}
  MODULE_TYPE_FEATURE_OPTIONS = [['全記事', ''], ['新着記事', 'feature_1'], ['記事', 'feature_2']]

  attr_accessible :name, :title, :module_type, :module_type_feature, :wrapper_tag, :doc_style, :num_docs,
                  :upper_text, :lower_text

  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCategory::Content::CategoryType'
  validates_presence_of :content_id

  validates :name, :presence => true, :uniqueness => {:scope => :content_id}
  validates :title, :presence => true

  after_initialize :set_defaults

  def module_type_text
    MODULE_TYPE_OPTIONS.values.flatten(1).detect{|o| o.last == module_type }.try(:first).to_s
  end

  def module_type_feature_text
    MODULE_TYPE_FEATURE_OPTIONS.detect{|o| o.last == module_type_feature }.try(:first).to_s
  end

  def wrapper_tag_text
    WRAPPER_TAG_OPTIONS.detect{|o| o.last == wrapper_tag }.try(:first).to_s
  end

  private

  def set_defaults
    self.module_type ||= MODULE_TYPE_OPTIONS.values.flatten(1).first.last if self.has_attribute?(:module_type)
    self.module_type_feature ||= MODULE_TYPE_FEATURE_OPTIONS.first.last if self.has_attribute?(:module_type_feature)
    self.wrapper_tag ||= WRAPPER_TAG_OPTIONS.first.last if self.has_attribute?(:wrapper_tag)
    self.num_docs ||= 10 if self.has_attribute?(:num_docs)
  end
end
