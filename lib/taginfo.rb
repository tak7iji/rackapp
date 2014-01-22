# coding: utf-8

require 'net/http'
require 'json'

class TagInfo

  def initialize config
    @server = config["server"]
    @port   = config["port"]
  end

  def call env
    req = Rack::Request.new(env)
    id = %r|/info/(.+)|.match(req.fullpath).to_a[1]

    [200, {'Content-Type' => 'text/html'}, tag_info(id)]
  end

  def tag_info id
    data = (JSON.pretty_generate(JSON.parse(Net::HTTP.get_response(@server, "/v1/images/#{id}/json", @port).body)) if id)||""
    ["<a href=/>back</a><p><pre>", data, "</pre>"]
  end
end
