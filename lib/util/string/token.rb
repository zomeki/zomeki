class Util::String::Token
  def self.generate
    SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
  end

  def self.generate_unique_token(model, attribute)
    loop do
      token = self.generate
      break token if model.where(attribute => token).empty?
    end
  end
end
