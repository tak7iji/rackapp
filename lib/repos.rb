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
      repos = Dir.glob("**/").select{|e| e =~ %r|[/].+$|}.map{|e| e.chop.sub("library/","")}
  
      ["Docker Image List<br><ul>", create_body(repos).join, "</ul>"]
    rescue
      []
    end
  end

  def get_registry_path
    js = ""
    Dir.glob("/var/lib/docker/containers/*/config.json").find do |item|
      File.open(item) do |file| 
        js = JSON.load(file)
        js["State"]["Running"] && js["Args"].any?{|e| e =~ /docker-registry/}
      end
    end

    js["Volumes"]["/tmp/registry"] || "/var/lib/docker/#{get_root_dir(js['Driver'],js['ID'])}/tmp/registry"
  end

  def get_root_dir driver, id
    case driver
    when "devicemapper"
      "devicemapper/mnt/#{id}/rootfs"
    when "aufs"
      "aufs/mnt/#{id}"
    when "vfs"
      "vfs/dir/#{id}"
    end
  end

  def create_body repos
    repos.map do |e|
      "<li>#{@server}:#{@port}/#{e} (tags: #{create_tag_info(e)*', '})"
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

