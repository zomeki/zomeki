class Approval::Assignment < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :assignable, :polymorphic => true
  belongs_to :user, :class_name => 'Sys::User'

  validates :user_id, presence: true

  def user_label
    user.try(:name)
  end

  def user_id_label
    user_id
  end
end
