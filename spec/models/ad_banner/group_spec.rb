require 'spec_helper'

describe AdBanner::Banner do
  before do
    Core.initialize
    login_as(fg_find_or_create(:sys_user_site_admin).account)
    fg_find_or_create(:cms_site_first_example_com)
    Core.recognize_path("/#{ZomekiCMS::ADMIN_URL_PREFIX}/ad_banner/1/banners")
  end

  it 'has a valid factory' do
    group = FactoryGirl.build(:ad_banner_group_1)
    expect(group).to be_valid
  end

  it 'is invalid without a name' do
    group = FactoryGirl.build(:ad_banner_group_1, name: nil)
    expect(group).to have(1).error_on(:name)
  end

  it 'is invalid without a title' do
    group = FactoryGirl.build(:ad_banner_group_1, title: nil)
    expect(group).to have(1).error_on(:title)
  end

  context 'after initialize' do
    before do
      @group = FactoryGirl.build(:ad_banner_group_1)
    end

    it 'sets "public" as state' do
      expect(@group.state).to eq 'public'
    end

    it 'sets 10 as sort_no' do
      expect(@group.sort_no).to eq 10
    end
  end
end
