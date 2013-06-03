require 'spec_helper'

describe CommonMailer do
  describe 'plain' do
    let(:mail) { CommonMailer.plain(from: 'from@example.com',
                                    to: 'to@example.org',
                                    subject: 'Hello!',
                                    body: 'World!') }

    it 'renders the headers' do
      mail.should deliver_from('from@example.com')
      mail.should deliver_to('to@example.org')
      mail.should have_subject('Hello!')
    end

    it 'renders the body' do
      mail.should have_body_text(/World!/)
    end
  end
end
