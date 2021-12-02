require "crest"
require "jwt"
require "json"
require "uri"

require "./token"

module GoogleAuth
  class Credential
    TOKEN_PATH = "https://oauth2.googleapis.com/token"
    AUDIENCE   = "https://oauth2.googleapis.com/token"
    GRANT_TYPE = "urn:ietf:params:oauth:grant-type:jwt-bearer"

    SIGNING_ALGORITHM = JWT::Algorithm::RS256
    EXPIRY            = 60.seconds
    SKEW_SECONDS      = 3600.seconds
    TOKENS_CACHE      = {} of String => Token

    DEFAULT_USER_AGENT = "Google on Crystal"

    @scopes : String
    property token_path : String
    property audience : String
    property signing_key : String
    property key_id : String
    property user_agent : String
    property issuer : String

    def initialize(@issuer : String, @signing_key : String, @key_id : String, scopes : String | Array(String),  @sub : String = "", @token_path : String = TOKEN_PATH, @audience : String = AUDIENCE, @user_agent : String = DEFAULT_USER_AGENT)
      @scopes = scopes.is_a?(Array) ? scopes.join(" ") : scopes
    end

    def client_email : String
      @issuer
    end

    # https://developers.google.com/identity/protocols/OAuth2ServiceAccount
    def get_token : Token
      existing = TOKENS_CACHE[token_lookup]?
      return existing if existing && existing.current?

      request = Crest::Request.new(
        :POST,
        TOKEN_PATH,
        headers: headers,
        form: form,
        handle_errors: false
      )

      response = request.execute
      GoogleAuth::Exception.raise_on_failure(response)

      token = Token.from_json response.body
      token.expires = token.expires + token.expires_in.seconds - EXPIRY
      TOKENS_CACHE[token_lookup] = token

      token
    end

    private def form
      {
        "grant_type" => GRANT_TYPE,
        "assertion"  => jwt_token,
      }
    end

    private def assertion
      now = Time.utc
      result = {
        "iss"   => @issuer,
        "scope" => @scopes,
        "aud"   => AUDIENCE,
        "iat"   => (now - SKEW_SECONDS).to_unix,
        "exp"   => (now + EXPIRY).to_unix,
      }

      result["sub"] = @sub unless @sub.empty?

      result
    end

    private def headers
      {
        "Content-Type" => "application/x-www-form-urlencoded",
        "User-Agent"   => @user_agent,
      }
    end

    private def token_lookup
      "#{@scopes}_#{@sub}"
    end

    private def jwt_token
      JWT.encode(
        assertion,
        @signing_key,
        SIGNING_ALGORITHM,
        kid: key_id,
        alg: "RS256",
        typ: "JWT",
      )
    end
  end
end
