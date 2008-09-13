require 'spider.rb'
require 'spider/next_urls_in_sqs.rb'

class MyArray < Array
  def pop
    a_msg = super
    puts "pop: #{a_msg.inspect}"
    return a_msg
  end
  
  def push(a_msg)
    puts "push: #{a_msg.inspect}"
    super(a_msg)
  end
end

AWS_ACCESS_KEY = '0YA99M8Y09J2D4FEC602'
AWS_SECRET_ACCESS_KEY = 'Sc9R9uiwbFYz7XhQqkPvSK3Bbq4tPYPVMWyDlF+a'

#Spider.start_at("http://docs.huihoo.com/ruby/ruby-man-1.4/function.html") do |s|
Spider.start_at("http://www.google.com") do |s|
  #s.store_next_urls_with NextUrlsInSQS.new(AWS_ACCESS_KEY, AWS_SECRET_ACCESS_KEY)
  s.store_next_urls_with MyArray.new
  s.on(:every) do |a_url, resp, prior_url|
    puts a_url
  end
end