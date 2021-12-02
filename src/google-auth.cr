require "./google-auth/**"

module GoogleAuth
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}

  class Exception < ::Exception
    property http_status : HTTP::Status
    property http_body : String

    def initialize(@http_status, @http_body, @message = nil)
    end

    def self.raise_on_failure(response)
      unless response.success?
        raise new(response.status, response.body, "#{response.status.description}\n#{response.body}")
      end
    end
  end
end
