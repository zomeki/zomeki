# encoding: utf-8
class Cms::SiteSetting::FileTransfer < Cms::SiteSetting

  validates_uniqueness_of :value, :scope => :name

end
