class GpCategory::TemplateModule < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  WRAPPER_TAG_OPTIONS = [['li', 'li'], ['article', 'article'], ['section', 'section']]
  MODULE_TYPE_OPTIONS = {'カテゴリ一覧' => [['自カテゴリ以下全て', 'categories_1'],
                                            ['自カテゴリの1階層',  'categories_2'],
                                            ['自カテゴリの2階層',  'categories_3']],
                         '全記事一覧' => [['自カテゴリ以下全て',                                             'all_docs_1'],
                                          ['自カテゴリのみ ',                                                'all_docs_2'],
                                          ['自カテゴリ以下全て+ネスト（汎用カテゴリタイプの1階層目で分類）', 'all_docs_3'],
                                          ['自カテゴリのみ+ネスト（汎用カテゴリタイプの1階層目で分類）',     'all_docs_4'],
                                          ['自カテゴリ以下全て+組織 （グループで分類）',                     'all_docs_5'],
                                          ['自カテゴリのみ+組織（グループで分類）',                          'all_docs_6'],
                                          ['自カテゴリ直下のカテゴリ（カテゴリで分類）',                     'all_docs_7'],
                                          ['自カテゴリ直下のカテゴリ+階層目カテゴリ表示（カテゴリで分類）',  'all_docs_8']],
                         '最新記事一覧' => [['自カテゴリ以下全て',                                             'recent_docs_1'],
                                            ['自カテゴリのみ ',                                                'recent_docs_2'],
                                            ['自カテゴリ以下全て+ネスト（汎用カテゴリタイプの1階層目で分類）', 'recent_docs_3'],
                                            ['自カテゴリのみ+ネスト（汎用カテゴリタイプの1階層目で分類）',     'recent_docs_4'],
                                            ['自カテゴリ以下全て+組織 （グループで分類）',                     'recent_docs_5'],
                                            ['自カテゴリのみ+組織（グループで分類）',                          'recent_docs_6'],
                                            ['自カテゴリ直下のカテゴリ（カテゴリで分類）',                     'recent_docs_7'],
                                            ['自カテゴリ直下のカテゴリ+階層目カテゴリ表示（カテゴリで分類）',  'recent_docs_8']],
                         '記事一覧' => [['自カテゴリ以下全て',                                             'docs_1'],
                                        ['自カテゴリのみ ',                                                'docs_2'],
                                        ['自カテゴリ以下全て+ネスト（汎用カテゴリタイプの1階層目で分類）', 'docs_3'],
                                        ['自カテゴリのみ+ネスト（汎用カテゴリタイプの1階層目で分類）',     'docs_4'],
                                        ['自カテゴリ以下全て+組織 （グループで分類）',                     'docs_5'],
                                        ['自カテゴリのみ+組織（グループで分類）',                          'docs_6'],
                                        ['自カテゴリ直下のカテゴリ（カテゴリで分類）',                     'docs_7'],
                                        ['自カテゴリ直下のカテゴリ+階層目カテゴリ表示（カテゴリで分類）',  'docs_8']]}

  attr_accessible :name, :title, :module_type, :wrapper_tag, :doc_style, :num_docs

  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCategory::Content::CategoryType'
  validates_presence_of :content_id

  validates :name, :presence => true, :uniqueness => {:scope => :content_id}
  validates :title, :presence => true

  after_initialize :set_defaults

  def module_type_text
    MODULE_TYPE_OPTIONS.values.flatten(1).detect{|o| o.last == module_type }.try(:first).to_s
  end

  def wrapper_tag_text
    WRAPPER_TAG_OPTIONS.detect{|o| o.last == wrapper_tag }.try(:first).to_s
  end

  private

  def set_defaults
    self.wrapper_tag ||= WRAPPER_TAG_OPTIONS.first.last if self.has_attribute?(:wrapper_tag)
    self.num_docs ||= 10 if self.has_attribute?(:num_docs)
  end
end
