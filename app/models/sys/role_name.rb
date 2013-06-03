class Sys::RoleName < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Auth::Manager
  
  has_many :users_roles, :foreign_key => :role_id, :primary_key => :id,
    :class_name => 'Sys::UsersRole', :dependent => :destroy
    
  validates_presence_of :name, :title
end
