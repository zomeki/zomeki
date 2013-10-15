class Survey::Answer < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :form_answer
  validates_presence_of :form_answer_id

  belongs_to :question
  validates_presence_of :question_id
end
