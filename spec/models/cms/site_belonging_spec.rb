require 'spec_helper'

describe Cms::SiteBelonging do
  it 'is valid with site_id and group_id' do
    FactoryGirl.build(:cms_site_belonging,
                      site_id: 1, group_id: 1).should be_valid
  end

  it 'is invalid without site_id' do
    FactoryGirl.build(:cms_site_belonging,
                      site_id: nil, group_id: 1).should_not be_valid
  end

  it 'is invalid without group_id' do
    FactoryGirl.build(:cms_site_belonging,
                      site_id: 1, group_id: nil).should_not be_valid
  end
end
