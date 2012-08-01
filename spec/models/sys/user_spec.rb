require 'spec_helper'

describe Sys::User do
  before(:all) do
    @system_admin = fg_find_or_create(:sys_user_system_admin)
    @site_admin = fg_find_or_create(:sys_user_site_admin)
  end

  context 'when id is 1' do
    subject { @system_admin }
    it { should be_root }

    it 'can not be deleted' do
      expect { @system_admin.destroy }.to raise_error
    end
  end

  context 'when id is not 1' do
    subject { @site_admin }
    it { should_not be_root }

    it 'can not be deleted' do
      expect { @site_admin.destroy }.to_not raise_error
    end
  end
end
