require 'spec_helper'

describe PublicBbs::Category do
  describe 'when build' do
    context 'with valid arguments' do
      subject { FactoryGirl.build(:valid_category) }
      it { should be_valid }
    end

    context 'without parent_id' do
      subject { FactoryGirl.build(:valid_category, :parent_id => nil) }
      it { should have(1).error_on(:parent_id) }
    end

    context 'without state' do
      subject { FactoryGirl.build(:valid_category, :state => nil) }
      it { should have(1).error_on(:state) }
    end

    context 'without name' do
      subject { FactoryGirl.build(:valid_category, :name => nil) }
      it { should have(1).error_on(:name) }
    end

    context 'without title' do
      subject { FactoryGirl.build(:valid_category, :title => nil) }
      it { should have(1).error_on(:title) }
    end
  end
end
