class Survey::Question < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  FORM_TYPE_OPTIONS = [['入力/1行（テキストフィールド）', 'text_field'], ['入力/複数行（テキストエリア）', 'text_area'],
                       ['選択/単数回答（プルダウン）', 'select'], ['選択/単数回答（ラジオボタン）', 'radio_button'],
                       ['選択/複数回答（チェックボックス）', 'check_box'],['自由形式','free'],['入力/1行（メールアドレス）', 'text_field_email']]
  REQUIRED_OPTIONS = [['必須', true], ['任意', false]]

  default_scope order("#{self.table_name}.sort_no IS NULL, #{self.table_name}.sort_no")

  belongs_to :form
  validates_presence_of :form_id

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  validates_presence_of :state

  validates :title, :presence => true
  validates :sort_no, :presence => true

  after_initialize :set_defaults

  scope :public, where(state: 'public')

  def content
    form.content
  end

  def form_options_for_select
    form_options.gsub("\r\n", "\n").gsub("\r", "\n").split("\n")
  end

  def email_field?
    form_type == 'text_field_email'
  end

  private

  def set_defaults
    self.state     = STATE_OPTIONS.first.last     if self.has_attribute?(:state) && self.state.nil?
    self.form_type = FORM_TYPE_OPTIONS.first.last if self.has_attribute?(:form_type) && self.form_type.nil?
    self.required  = REQUIRED_OPTIONS.first.last  if self.has_attribute?(:required) && self.required.nil?
    self.sort_no = 10 if self.has_attribute?(:sort_no) && self.sort_no.nil?
  end
end
