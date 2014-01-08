# coding: utf-8

require "./lib/repos.rb"
require "./lib/taginfo.rb"

map "/" do
  run DockerRepos.new
end

map "/info" do
#  run lambda {|env| [200, {'Content-Type' => 'text/html'}, ["<html>","OK","</html>"]]}
  run TagInfo.new
end
