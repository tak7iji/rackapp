require 'json'

module AppConfig
#  attr_reader :config

  def load_config
    data = File.open("conf/config.json") do |file|
      file.readlines.join
    end
    JSON.parse(data)
  end
end
