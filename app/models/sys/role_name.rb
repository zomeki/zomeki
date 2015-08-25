class Sys::RoleName < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Auth::Manager
  
  has_many :users_roles, :foreign_key => :role_id, :primary_key => :id,
    :class_name => 'Sys::UsersRole', :dependent => :destroy
    
  validates_presence_of :name, :title

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        self.and_keywords v, :title, :name
      end
    end if params.size != 0

    return self
  end

end
