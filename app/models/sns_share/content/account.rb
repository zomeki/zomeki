class SnsShare::Content::Account < Cms::Content
  default_scope where(model: 'SnsShare::Account')

  has_many :accounts, :foreign_key => :content_id, :class_name => 'SnsShare::Account', :dependent => :destroy

  after_create :prepare_accounts

  def prepare_accounts # keep public
    SnsShare::Account::SUPPORTED_PROVIDERS.each do |provider|
      accounts.create(provider: provider) unless accounts.find_by_provider(provider)
    end
  end
end
