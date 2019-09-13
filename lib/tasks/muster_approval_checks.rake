TIMEOUT_SECONDS=30

class HTTPClient
  class << self
    TIMEOUT_SECONDS = 25

    def request(host, path, timeout)
      uri = URI.parse("#{host}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.read_timeout = timeout
      http.open_timeout = timeout
      yield http, uri
    end

    def head(host, path, timeout=TIMEOUT_SECONDS)
      request(host, path, timeout) do |http, uri|
        http.request(Net::HTTP::Head.new(uri.request_uri))
      end
    end 
  end

  class Error < StandardError
  end
end

namespace :muster do
  task :version_check, :url do |t, args|
    retry_count = 0
    sleep_time = 30
    begin
      puts "Checking X-Version header..."
      header = nil
      response = HTTPClient.head(args[:url], '/')
      header = response['x-version']
      puts "Received header: #{header}, expecting header #{ENV['MUSTER_SHA']}"
      raise HTTPClient::Error if header != ENV['MUSTER_SHA']
    rescue HTTPClient::Error, Net::OpenTimeout, Net::ReadTimeout
      retry_count = retry_count + 1
      raise "X-Version header was #{header}, should be #{ENV['MUSTER_SHA']}" if retry_count > 3
      puts "Sleeping #{sleep_time} seconds before retrying..."
      sleep(sleep_time)
      retry
    end
  end
end
