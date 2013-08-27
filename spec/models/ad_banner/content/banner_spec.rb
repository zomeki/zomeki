require 'spec_helper'

describe AdBanner::Content::Banner do
  before do
    Core.user = FactoryGirl.build(:sys_user_system_admin)
    Core.user_group = Core.user.group
  end

  subject { AdBanner::Content::Banner }
  it { should < Cms::Content }

  describe :all do
    it 'identifies own class' do
      expect {
        FactoryGirl.create(:cms_content_map_marker_1)
        FactoryGirl.create(:cms_content_ad_banner_banner_1)
        FactoryGirl.create(:cms_content_ad_banner_banner_2)
      }.to change(AdBanner::Content::Banner, :count).by(2)
    end
  end
end
