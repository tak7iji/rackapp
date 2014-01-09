# coding: utf-8

require "./lib/repos.rb"
require "./lib/taginfo.rb"
require "./lib/appconfig.rb"

extend AppConfig

config = load_config

map "/" do
  run DockerRepos.new config
end

map "/info" do
  run TagInfo.new config
end
