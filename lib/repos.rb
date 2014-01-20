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
    begin
      Dir.chdir("#{get_registry_path}/repositories")
      repos = Dir.glob("**/").select{|e| e =~ /[\/].+$/}.map{|e| e.chop.sub("library/","")}
  
      ["Docker Image List<br><ul>", create_body(repos).join, "</ul>"]
    rescue
      []
    end
  end

  def get_registry_path
    js = ""
    Dir.glob("/var/lib/docker/containers/*/config.json").find do |item|
      js = File.open(item) { |file| JSON.load(file) }
      js["State"]["Running"] && js["Args"].any?{|e| e =~ /docker-registry/}
    end

    rootdir = case js["Driver"]
              when "devicemapper"
                "devicemapper/mnt/#{js['ID']}/rootfs"
              when "aufs"
                "aufs/mnt/#{js['ID']}"
              when "vfs"
                "vfs/dir/#{js['ID']}"
              end
    js["Volumes"]["/tmp/registry"] || "/var/lib/docker/#{rootdir}/tmp/registry"
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

