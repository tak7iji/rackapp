# coding: utf-8

require 'net/http'
require 'json'
require_relative 'appconfig'

class TagInfo

  include AppConfig

  def initialize
    load
    @server = config["server"]
    @port   = config["port"]
  end

  def call env
    req = Rack::Request.new(env)

    id = $1 if req.fullpath =~ %r|/info/(.+)|

    [200, {'Content-Type' => 'text/html'}, tag_info(id)]
  end

  def tag_info id
    data = (JSON.pretty_generate(JSON.parse(Net::HTTP.get_response(@server, "/v1/images/#{id}/json", @port).body)) if id) || ""
    ["<a href=/>back</a><p><pre>", data, "</pre>"]
  end
end
