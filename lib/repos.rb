# coding: utf-8

require 'net/http'
require 'json'

class DockerRepos
  def initialize config
    @server = config["server"]
    @port   = config["port"]
  end

  def call env
    [200, {'Content-Type' => 'text/html'}, image_list]
  end

  def image_list
    Dir.chdir("#{get_registry_path}/repositories")
    repos = Dir.glob("**/").select{|e| e =~ /[\/].+$/}.map{|e| e.chop.sub("library/","")}

    ["Docker Image List<br><ul>", create_body(repos).join, "</ul>"]
  end

  def get_registry_path
    reg = IO.popen('docker ps -notrunc') do |io|
      io.readlines.find {|item| item =~ %r|stackbrew/registry|}.split[0]
    end

    js = File.open("/var/lib/docker/containers/#{reg}/config.json") {|file| JSON.load(file)}
    rootdir = case js["Driver"]
              when "devicemapper"
                "/rootfs"
              else
                ""
              end
    js["Volumes"]["/tmp/registry"] || "/var/lib/docker/#{js["Driver"]}/mnt/#{reg}#{rootdir}/tmp/registry"
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

