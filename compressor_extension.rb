# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class CompressorExtension < Radiant::Extension
  version "1.0"
  description "Removes whitespace from the cached responses."
  url "http://saturnflyer.com/"
  
  def activate
    ResponseCache.class_eval {
      def cache_page(metadata, content, path)
        return unless perform_caching

        if path = page_cache_path(path)
          benchmark "Cached page: #{path}" do
            FileUtils.makedirs(File.dirname(path))
            #dont want yml without data
            content_result = Radiant::Config['response_cache.compressed?'] == true ? content.gsub(/[\t\r\n\f\b]/,'').gsub(/\s+/,' ') : content
            File.open("#{path}.data", "wb+") { |f| f.write(content_result) }
            File.open("#{path}.yml", "wb+") { |f| f.write(metadata) }
          end
        end
      end
    }
  end
  
  def deactivate
    # admin.tabs.remove "Compressor"
  end
  
end
