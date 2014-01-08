require 'json'

module AppConfig
  attr_reader :config

  def load
    data = File.open("conf/config.json") do |file|
      file.readlines.join
    end
    @config = JSON.parse(data)
  end
end
