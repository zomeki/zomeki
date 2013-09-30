class Survey::Question < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  FORM_TYPE_OPTIONS = [['入力/1行（テキストフィールド）', 'text_field'], ['入力/複数行（テキストエリア）', 'text_area'],
                       ['選択/単数回答（プルダウン）', 'select'], ['選択/単数回答（ラジオボタン）', 'radio_button'], ['選択/複数回答（チェックボックス）', 'check_box']]
  REQUIRED_OPTIONS = [['必須', true], ['任意', false]]

  belongs_to :form
  validates_presence_of :form_id

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  validates_presence_of :state

  validates :title, :presence => true
  validates :sort_no, :presence => true

  after_initialize :set_defaults

  def content
    form.content
  end

  def required=(new_required)
    write_attribute(:required, !['false', '0', 'f', 'no'].include?(new_required))
  end

  private

  def set_defaults
    self.state     = STATE_OPTIONS.first.last if self.has_attribute?(:state) && self.state.nil?
    self.form_type = FORM_TYPE_OPTIONS.first.last if self.has_attribute?(:form_type) && self.form_type.nil?
    self.required  = REQUIRED_OPTIONS.first.last if self.has_attribute?(:required) && self.required.nil?
    self.sort_no   = 10 if self.has_attribute?(:sort_no) && self.sort_no.nil?
  end
end
