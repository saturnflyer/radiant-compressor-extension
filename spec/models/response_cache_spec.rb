require File.dirname(__FILE__) + '/../spec_helper'

describe ResponseCache do
  class SilentLogger
    def method_missing(*args); end
  end
  
  class TestResponse < ActionController::TestResponse
    def initialize(body = '', headers = {})
      self.body = body
      self.headers = headers
    end
  end
  
  before :all do
    @dir = File.expand_path("#{RAILS_ROOT}/test/cache")
    @baddir = File.expand_path("#{RAILS_ROOT}/test/badcache")
    @old_perform_caching = ResponseCache.defaults[:perform_caching]
    ResponseCache.defaults[:perform_caching] = true
  end
  
  before :each do
    FileUtils.rm_rf @baddir
    @cache = ResponseCache.new(
      :directory => @dir,
      :perform_caching => true
    )
    @cache.clear
  end
  
  after :each do
    FileUtils.rm_rf @dir if File.exists? @dir
  end
  
  after :all do
    ResponseCache.defaults[:perform_caching] = @old_preform_caching
  end
  
  it "should cache content with whitespace when Radiant::Config['response_cache.compressed?'] is blank" do
    result = @cache.cache_response('test', response('<html>
    <table align="center">content <em>is</em>  right  here  .</table>
    </html>', 'Content-Type' => 'text/plain'))
    cached = @cache.update_response('test', response, ActionController::TestRequest)
    cached.body.should == '<html>
    <table align="center">content <em>is</em>  right  here  .</table>
    </html>'
  end
  
  it "should cache content without whitespace when Radiant::Config['response_cache.compressed?'] is set to true" do
    Radiant::Config['response_cache.compressed?'] = true
    result = @cache.cache_response('test', response('<html>
    <table align="center">content <em>is</em>  right  here  .</table>
    </html>', 'Content-Type' => 'text/plain'))
    cached = @cache.update_response('test', response, ActionController::TestRequest)
    cached.body.should == '<html> <table align="center">content <em>is</em> right here .</table> </html>'
  end
  
  private
  
    def file(filename)
      open(filename) { |f| f.read } rescue ''
    end
    
    def response(*args)
      TestResponse.new(*args)
    end
  
end
