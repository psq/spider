require 'rubygems'
require 'spider'

DOMAIN = $*[0]  #temporary hack

def strip_anchor(url)
  url.to_s.gsub(/#.*/,'')
end

def strip_port(url)
  u = url.is_a?(URI) ? url : URI.parse(url)
  "#{u.scheme}://#{u.host}#{u.path}"
end

def strip_trailing_slash(url)
  url.to_s.gsub(/\/$/,'')
end

class ExpireLinks # < Hash
  def <<(url)
    @@h ||= Hash.new
    url = strip_trailing_slash(strip_port(strip_anchor(url)))
    @@h[url] = Time.now
  end
  def include?(url)
    @@h ||= Hash.new
    url = strip_trailing_slash(strip_port(strip_anchor(url)))
    @@h[url] && ((Time.now + 86400) >= @@h[url])
  end
end

class NextLinks
  
  def initialize
    @@a ||= Array.new
  end
  
  def push(value)
    url = value.values[0]
    return unless url =~ /^http:\/\/(www\.){0,1}#{DOMAIN}/i
    return if url =~ /\.(css|js|gif|jpeg|jpg|png)$/i
    
    #normalize to "http://www.domain.com" and strip anchor text
    url = strip_anchor(url.gsub(/^http:\/\/#{DOMAIN}/i, "http://www.#{DOMAIN}"))

    @@a.push(value.keys[0] => url) unless @@a.include?(value.keys[0] => url)
  end
  
  def empty?
    @@a.empty?
  end
  
  def pop
    @@a.pop
  end

  def self.queue_size
    @@a.size
  end
end

Spider.start_at("http://www.#{DOMAIN}") do |s|

  total_count ||= 0
  
  s.add_url_check do |a_url|
    a_url =~ /^http:\/\/(www\.){0,1}#{DOMAIN}/i
  end

  s.store_next_urls_with NextLinks.new
  
  s.check_already_seen_with ExpireLinks.new

  s.on :failure do |a_url, resp, prior_url|
    puts "URL failed with #{resp}: #{a_url}"
    puts " linked from #{prior_url}"
  end

  s.on :success do |a_url, resp, prior_url|
    total_count += 1
    puts "#{strip_trailing_slash(strip_port(strip_anchor(a_url)))}: #{resp.code} (#{total_count} - #{NextLinks.queue_size})"
    # puts resp.body
  end

end
