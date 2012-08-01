require 'spec_helper'

describe PublicBbs::Public::Node::ThreadsController do
  describe 'GET :new' do
    context 'without OAuth login' do
      before { pending; get :new }

      describe 'response' do
        subject { response }
        it { should redirect_to('/_auth/facebook') }
      end
    end
  end
end
