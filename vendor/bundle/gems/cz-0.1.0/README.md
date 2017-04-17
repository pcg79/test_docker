# CZ

Create, configure, and deploy apps at CareZone.

## Installation

    $ gem install cz -s http://gems.czops.net:9292

## Usage

### CLI

In your project directory:

    $ cz init

This will set up the files you need to get started with a typical Rails 5+ app.
Season to taste.

To view available commands, run:

    $ cz help

### CZ::Config

If you're writing a Ruby project, you might like to add the gem to your Gemfile.
If you do so, you'll have access to a small but powerful configuration class
named `CZ::Config`.

`CZ::Config` instances provide read access to application configuration in a
number of formats, ideal for use in container-based applications that often load
secrets or other configuration snippets from files, be they YAML or otherwise.

The "vault" managed by `cz`, for instance, is dropped into your application's
`vault/` directory as either a flat directory of files or "projected" paths,
depending on your `deploy.yml` settings. If your application has only a few
small bits of secret configuration data, you might just store those strings in
files, or you might choose to project entire YAML files filled with secrets to
your app's `vault/`.

For non-secret data, you might choose to set a few environment variables and use
ERB to interpolate them into files in your app's repository, or store things
like test-mode API keyfiles in the repository. Whatever configuration data your
app has, `CZ::Config` can provide a home for it, whether in one or many named
`CZ::Config`s.

#### Creating CZ::Configs

`CZ::Config.load` takes one or more parameters as configuration sources and
returns a `CZ::Config` object.  These sources are deep-merged from left to
right, so keys in later configs can override all or part of more general ones.

Configuration sources are things with (potentially nested) key/value pairs,
such as:

* existing `CZ::Config` objects
* Hashes
* YAML files
* Directories. Yes, **directories**! A directory, after all, is just a list of
    entries that point to their contents, whether those are files or other
    directories.

So, let's say you have a very simple application vault set up using `cz`. When
unpacked for your application, it has a couple of small secrets:

    $ tree vault
    vault
    ├── database_password
    └── spiffy_api_key

    0 directories, 2 files

We might choose to add the following at the bottom of our
`config/application.rb`:

```ruby
# You could also choose to initialize this in an initializer, but then you'll
# need to update certain rake tasks to load the environment. We choose to do
# this here because the CZ Config is a top-level app concern.
Vault = CZ::Config.load(Rails.root + "vault")
```

You can now access the contents of those secrets like so:

```irb
> Vault.database_password
=> "super-sekrit-password"
> Vault.spiffy_api_key
=> "ALLYOURBASE"
```

You can cast any single configuration source to a `CZ::Config` via the
`CZ::Config()` method, so...

```ruby
Vault = CZ::Config(Rails.root + "vault")
```

...would do the same thing. This becomes useful when you decide you'd like to
mount multiple configuration sources at different places in a unified config:

```ruby
AppConfig = CZ::Config.load(
  'config/application.yml',              # Load some general app config stuff
  "config/application-#{Rails.env}.yml", # Overlay something more specific
  {
    # Put some stuff from another file in the same config object
    google_stuff: CZ::Config(Rails.root + 'config' + 'google_stuff.yml')
  }
)
```

If you'd like to interpolate secrets from your vault, your environment, or
anything else, you're of course free to run your YAML through any kind of
pre-processing you like and send it to `CZ::Config` as a hash.

```ruby
Vault = CZ::Config.load(Rails.root + "vault")
AppConfig = CZ::Config.load(
  YAML.load(ERB.new('monolithic-erb-config.yml').result(binding))[Rails.env],
  { vault: Vault },
  # ...and so on
)
```

#### Using CZ::Configs

You should use as many or as few toplevel config objects as make sense for your
application. They'll all work the same, and can be easily combined if you wish.

There are several ways to retrieve configuration data from a `CZ::Config`, and
it's easier to understand with a demo:

```ruby
Vault = CZ::Config(Rails.root + 'vault')

AppConfig = CZ::Config.load(
  # Let's start with a plain old YAML configuration file...
  Rails.root + 'config/some-yaml-config.yml',
  # ...then merge in a directory with some subdirectories and files...
  Rails.root + 'config/some-yaml-config.yml',
  # ...and finish by merging our vault into our global config using a hash.
  { vault: Vault }
)

# You already saw method calls, above
AppConfig.key # => "value"

# You can chain them together to traverse the configuration map
AppConfig.key_with_subkey.subkey # => "subkey value"

# This works no matter where you got your data from
AppConfig.vault.spiffy_api_key # => "ALLYOURBASE"
AppConfig.subdirectory.file    # => "subdirectory file contents"

# If you have keys that don't make good method names, treat your config like a
# filesystem (some of it might actually _be_ a filesystem, after all)
AppConfig[:key]                # => "value" (everyone loves symbols)
AppConfig['subdirectory/file'] # => "subdirectory file contents"
# But even if it's not...
AppConfig['key_with_subkey/subkey'] # => "subkey value"

# If you've got a three-element array in your configuration, you can index it
AppConfig['key_with_array/0']  # => "zero"
AppConfig['key_with_array/1']  # => "one"
AppConfig['key_with_array/-1'] # => "two"

# The above only works on the last key, however. If you're storing hashes of
# data inside your arrays, you're gonna need to treat 'em as hashes, not
# `CZ::Config` objects. Sorry. There's such a thing as _too much_ magic, ya
# know.

# If you access a key that doesn't exist, you're gonna have a bad time:
AppConfig.nonexistent_key
# => CZ::Config::MissingKeyError: Missing key: nonexistent_key

# But if you use the path syntax, you can specify a default:
AppConfig[:nonexistent_key, default: 'go fish'] # => "go fish"
# It works if any part of the key is missing
AppConfig['subdirectory/nonexistent_file', default: 'go fish'] # => "go fish"
AppConfig['nonexistent_subdirectory/file', default: 'go fish'] # => "go fish"
```

`CZ::Config`'s main opinion is that it should not force its opinions on you. If
you feed it something that could conceivably be a configuration source, it'll
dutifully handle things for you, without a bunch of configuration tweaks needed.

### Conventions

This section is coming soon.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to our gem server.

## License

All rights reserved, CareZone.
