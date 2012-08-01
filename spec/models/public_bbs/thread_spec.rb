require 'spec_helper'

describe PublicBbs::Thread do
  describe 'when build' do
    context 'with valid arguments' do
      subject { FactoryGirl.build(:valid_thread) }
      it { should be_valid }
    end

    context 'without state' do
      subject { FactoryGirl.build(:valid_thread, :state => nil) }
      it { should have(1).error_on(:state) }
    end

    context 'without title' do
      subject { FactoryGirl.build(:valid_thread, :title => nil) }
      it { should have(1).error_on(:title) }
    end

    context 'without body' do
      subject { FactoryGirl.build(:valid_thread, :body => nil) }
      it { should have(1).error_on(:body) }
    end

    context 'without user' do
      subject { FactoryGirl.build(:valid_thread, :user_id => nil) }
      it { should have(1).error_on(:user_id) }
    end
  end
end
