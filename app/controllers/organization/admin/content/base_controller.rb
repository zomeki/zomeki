class Organization::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    Organization::Content::Group
  end
end
