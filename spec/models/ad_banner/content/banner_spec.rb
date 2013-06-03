require 'spec_helper'

describe AdBanner::Content::Banner do
  before do
    Core.user = FactoryGirl.build(:sys_user_system_admin)
    Core.user_group = Core.user.group
    [:cms_content_map_marker_1,
     :cms_content_ad_banner_banner_1,
     :cms_content_ad_banner_banner_2].each do |id|
      FactoryGirl.create(id)
    end
  end

  subject { AdBanner::Content::Banner }
  it { should < Cms::Content }

  describe :all do
    subject { AdBanner::Content::Banner.all }
    it { should have(2).items }
  end
end
