# coding: utf-8

require 'net/http'
require 'json'
require_relative 'appconfig'

class DockerRepos

  include AppConfig

  def initialize
    load
    @server = config["server"]
    @port   = config["port"]
    @docker_home = config["docker_home"]
  end

  def call env
    [200, {'Content-Type' => 'text/html'}, image_list]
  end

  def image_list
    reg = IO.popen('docker ps -notrunc') do |io|
      io.readlines.select {|item| item =~ %r|stackbrew/registry|}[0]
    end

    Dir.chdir("#{@docker_home}/devicemapper/mnt/#{reg.split[0]}/rootfs/tmp/registry/repositories")
    repos = Dir.glob("**/").select{|e| e =~ /[\/].+$/}.map{|e| e.chop.sub("library/","")}

    ["Docker Image List<br><ul>", create_body(repos).join, "</ul>"]
  end

  def create_body repos
    repos.map do |e|
      "<li>#{@server}:#{@port}/#{e} (tags: #{create_tag_info(e).join(', ')})"
    end
  end

  def create_tag_info repo
    get_tags(repo).map do |k, v|
      "<a href=/info/#{v}>#{k}</a>"
    end
  end

  def get_tags repo
    JSON.parse(Net::HTTP.get_response(@server,"/v1/repositories/#{repo}/tags",@port).body)
  end
end

