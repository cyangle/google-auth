# google-auth

TODO: Write a description here

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     google-auth:
       github: cyangle/google-auth
       version: ~> 0.1.0
   ```

2. Run `shards install`

## Usage

```crystal
require "google-auth"
```

Load credential from json file:

```crystal
cred = GoogleAuth::FileCredential.new(
  file_path: "/file/path/to/credential/json/file",
  scopes: "https://www.googleapis.com/auth/cloud-platform", # String | Array(String)
  user_agent: "crystal/client",
)
```

Get access token:

```crystal
token = cred.get_token

puts token.token_type # => Bearer
puts token.access_token
```

## Development

Install dependencies

```shell
shards
```

Run the tests:

```shell
crystal spec
```

Run lints

```shell
./bin/ameba
crystal tool format --check
```

## Contributing

1. Fork it (<https://github.com/cyangle/google-auth/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chao Yang](https://github.com/cyangle) - creator and maintainer
