require 'spec_helper'

describe AdBanner::Banner do
  before do
    Core.user = FactoryGirl.build(:sys_user_system_admin)
    Core.user_group = Core.user.group
  end

  it 'has a valid factory' do
    banner = FactoryGirl.build(:ad_banner_banner_1)
    banner.skip_upload
    expect(banner).to be_valid
  end

  it 'is invalid without a name' do
    banner = FactoryGirl.build(:ad_banner_banner_1, name: nil)
    banner.skip_upload
    expect(banner).to have(1).error_on(:name)
  end

  it 'is invalid without a title' do
    banner = FactoryGirl.build(:ad_banner_banner_1, title: nil)
    banner.skip_upload
    expect(banner).to have(1).error_on(:title)
  end

  it 'is invalid without a content' do
    banner = FactoryGirl.build(:ad_banner_banner_1, content: nil)
    banner.skip_upload
    expect(banner).to have(1).error_on(:content_id)
  end

  it 'is invalid without a state' do
    banner = FactoryGirl.build(:ad_banner_banner_1, state: nil)
    banner.skip_upload
    expect(banner).to have(1).error_on(:state)
  end

  it 'is invalid without an advertiser name' do
    banner = FactoryGirl.build(:ad_banner_banner_1, advertiser_name: nil)
    banner.skip_upload
    expect(banner).to have(1).error_on(:advertiser_name)
  end

  it 'is invalid without an url' do
    banner = FactoryGirl.build(:ad_banner_banner_1, url: nil)
    banner.skip_upload
    expect(banner).to have(1).error_on(:url)
  end
end
