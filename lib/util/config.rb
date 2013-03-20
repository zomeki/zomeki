class Util::Config
  @@cache = {}
  
  def self.load(name, attribute = nil)
    name = name.to_s
    yml = self.read(name)
    return yml unless attribute
    return yml[attribute.to_s]
  end
  
private
  def self.read(filename)
    unless @@cache[filename]
      config = ::File.join(Rails.root, 'config', filename + '.yml')
      @@cache[filename] = YAML.load_file(config)[Rails.env]
    end
    return @@cache[filename]
  end
end
