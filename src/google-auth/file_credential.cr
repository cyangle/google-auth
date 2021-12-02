require "./credential"
require "./token"

module GoogleAuth
  class FileCredential
    getter :file_path, :scopes, :user_agent, :sub, :client_secret
    @client_secret : Hash(String, String)

    def initialize(@file_path : String, @scopes : String | Array(String), @user_agent : String = "Switch")
      @client_secret = process_auth_file
    end

    def get_token : Token
      GoogleAuth::Credential.new(
        issuer: issuer,
        signing_key: signing_key,
        scopes: scopes,
        sub: sub,
        key_id: key_id,
        token_path: token_path,
        audience: audience,
        user_agent: user_agent,
      ).get_token
    end

    def token_path
      client_secret["token_uri"]
    end

    def audience
      client_secret["token_uri"]
    end

    def key_id : String
      client_secret["private_key_id"]
    end

    def signing_key : String
      client_secret["private_key"]
    end

    def client_email : String
      client_secret["client_email"]
    end

    def issuer : String
      client_secret["client_email"]
    end

    def sub : String
      client_secret["client_email"]
    end

    private def process_auth_file : Hash(String, String)
      raise "error reading file: #{file_path}" unless File.file?(file_path)

      auth_file = File.read(file_path)

      Hash(String, String).from_json(auth_file)
    end
  end
end
