require 'spec_helper'

describe AdBanner::Admin::Content::BaseController do
  subject { AdBanner::Admin::Content::BaseController }
  it { should < Cms::Admin::Content::BaseController }
end
