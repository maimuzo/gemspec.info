require 'open-uri'
require 'yaml'

class PluginPack
  attr_reader :plugins, :name
  attr_accessor :description, :author, :email, :website
  
  def initialize(name)
    @name = name
    @plugins = []
    @description = ''
    @author = ''
    @email = ''
    @website = ''
  end
  
  def add_plugin(name, source)
    @plugins << Plugin.new(source, name)
  end
end

class PluginPackPlugin
  attr_reader :name, :source
  
  def initialize(name, source)
    @name, @source = name, source
  end
  
  def to_svn_external
    "#{@name} #{@source}"
  end
end

class PluginPackParser
  def self.parse_spec(spec)
    pack_spec = YAML.parse(spec)
    pack_meta = self.parse_pack_meta(pack_spec)
    pack_plugins = self.parse_pack_plugins(pack_spec)
    return nil if pack_plugins.empty?
    pack_name = pack_meta.delete('name') || 'Untitled Pack'
    pack = PluginPack.new(pack_name)
    pack_meta.each_pair { |key, value| pack.send("#{key}=", value) if pack.respond_to?(key) }
    pack_plugins.each_pair { |name, source| pack.add_plugin(name, source) }
    pack
  end
  
  def self.parse_spec_file(spec_file_or_url)
    self.parse_spec(open(spec_file_or_url))
  end
  
  def self.parse_pack_meta(pack_spec)
    pack_meta = {}
    return pack_meta if pack_spec['about'].nil?
    pack_spec['about'].children_with_index.each do |meta|
      key = meta[1].value
      value = pack_spec['about'][key].value
      pack_meta[key] = value
    end
    pack_meta
  end
  
  def self.parse_pack_plugins(pack_spec)
    plugins = {}
    return plugins if pack_spec['plugins'].nil? or pack_spec['plugins'].children.nil?
    pack_spec['plugins'].children_with_index.each do |p|
      name = p[1].value
      next if pack_spec['plugins'][name].nil?
      source = pack_spec['plugins'][name].value
      plugins[name] = source
    end
    plugins
  end
end