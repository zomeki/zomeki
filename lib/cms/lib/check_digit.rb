# old version
module Cms::Lib::CheckDigit
  def check_digit(code, type = "m10w31")
    digit = 0
    code.to_s.split(//).reverse.each_with_index do |chr, idx|
      digit += chr.to_i * (idx.even? ? 3 : 1)
    end
    digit = (10 - (digit % 10)) % 10
    return digit.to_s
  end
  
  def add_check_digit(code, type = "m10w31")
    return code.to_s + check_digit(code, type)
  end
end