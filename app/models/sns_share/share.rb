class SnsShare::Share < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :sharable, polymorphic: true
  validates_presence_of :sharable_type, :sharable_id
  belongs_to :account
  validates_presence_of :account_id
end
