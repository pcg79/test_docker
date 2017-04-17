# CZ

Create, configure, and deploy apps at CareZone.

## Installation

    $ gem install cz -s http://gems.czops.net:9292

## Usage

If you'd just like to see a sample application that's been set up according to
current best practices, please visit the [cz_rails
repository](https://github.com/carezone/cz_rails).

For a discussion of common usage scenarios, have a look at [USAGE.md](USAGE.md).

### CLI

To view available commands, run:

    $ cz help

To get started, in your project directory, run:

    $ cz init

This will set up the files you need to get started with a typical Rails 5+ app,
by default.

For more information about the conventions that your app will be expected to
follow, see ["Conventions"](#conventions), below. For information about the
files you just created, though, read on.

#### Life after `cz init`

After you set run `cz init`, you'll have a tree something like this in your
repository:

    ├── .dockerignore
    ├── .gitignore
    ├── Dockerfile.deploy
    ├── Dockerfile.dev
    ├── cz
    │   ├── bootstrap
    │   ├── build
    │   ├── clean
    │   ├── console
    │   ├── environment
    │   ├── health-check
    │   ├── idle
    │   ├── post-deploy
    │   ├── pre-deploy
    │   ├── run-once
    │   └── start
    ├── cz.yml
    ├── deploy.yml
    ├── docker-compose.yml
    └── vault
        └── .keep

We won't discuss the `.dockerignore` and `.gitignore` files, except to say that
you should always allow `cz init` to overwrite whatever you have -- you can
merge in any of your own customizations afterwards. Let's talk about the rest of
what's here.

##### Dockerfile.dev and Dockerfile.deploy

The first thing you might notice is that there is not a `Dockerfile` in your app
directory after running `cz init`. Instead, you'll have a `Dockerfile.dev` and
`Dockerfile.deploy`.

For day-to-day development, you'll be working with the image created from
`Dockerfile.dev`. When it comes time to create a deployable image for a given
environment, we'll use that development image to build your application's
deployment artifacts, then build the deployment image, only including those
dependencies necessary for your deployed application to run in a staging or
production environment.

Don't worry about when to build which, as `cz build` takes care of doing the
right thing for you. Just be sure that when you edit either file, you're only
including the things that are necessary for that environment.

##### docker-compose.yml

We recommend using Docker Compose for local development, and the default
`docker-compose.yml` is set up to illustrate how that might look for an app
with a couple of dependencies. Depending on the language and framework you're
using, you might notice that initial application startup time is a bit slow
through Docker. This is due to some filesystem [performance
issues](https://github.com/docker/for-mac/issues/77) in the current version of
Docker for Mac. Some
[improvements](https://github.com/docker/docker/pull/31047) are planned for the
April release of Docker for Mac, so we're hopeful these will be resolved soon.
Even so, after initial startup, you should find that your development
experience is largely unchanged, except that it now more closely mirrors the
environment your app will be running in, since the app is now running inside a
container.

##### cz.yml

The `cz.yml` file tells `cz`:

* what your app is named
* where its Docker image repository lives
* Which developers at CareZone should be able to decrypt your app's secrets
    (this is required to add secrets to the app, and also to deploy)
* What servers will host your app's containers when you deploy to a given
    environment

You won't need to make many tweaks to this file, aside from maintaining the list
of developers and specifying the names of any servers you've been provided.

##### deploy.yml

When you deploy to an environment, `deploy.yml` tells the servers how to go
about setting up your application, and how to launch it, once it's been set up.
You can configure environment variables, volume mounts, and port exposure very
similarly to `docker-compose.yml`. You'll have a separate stanza for each
container role that your app starts. We'll discuss those in more detail shortly.

You'll also be able to configure the way a server will run your app's `run-once`
script in the same way. It's most likely going to mirror one of the other roles,
so use YAML anchors where you can, to minimize duplication.

##### vault/

The `vault` directory is an auto-mounted volume that contains your app's
secrets for a given deploy.  By default, each key in your app's `vault.yml`
(maintained by the `cz vault` command) will be decrypted and unpacked in this
directory with a filename the same as its key name, readable and writable by
the `root` user and any user in the `vault` group. If you like, you may unpack
only a subset of those secrets, or control file modes and "project" them to an
alternate location within the "vault" directory. Examples are provided in the
comments of the generated file.

##### cz/

The `cz` directory contains the scripts that perform the bulk of the
Docker-related work involved in building, deploying, and starting your
application. These are heavily commented and are where you should perform any
customization to the way your application is deployed.

* `bootstrap` is the script that gets called when a developer clones the app's
    repository and runs `cz bootstrap`. It should perform any one-time setup
    that is needed to get the app ready to run, including configuring the app's
    database from a fresh launch of a PostgreSQL image.
* `build` gets run when you run `cz build [environment]`. Depending on whether
    the environment you're building for is deployable (defined as "listed as
    an environment in `cz.yml`) it will build your application's artifacts for
    local execution in a volume mount, or for copying to a deployment image. The
    example file should be generally sufficient for Rails apps, but feel free
    to customize as you see fit.
* `clean` will do the opposite of build. It will clean up any built artifacts,
    for both deployable and non-deployable builds.
* `console` launches `/bin/sh` by default. When `cz console` runs, it execs this
    script in an already-running container (via Docker Compose) or starts a new
    container with this script as its command.
* `environment` is the entrypoint of images we build. When your application is
    launched, whether via Docker Compose or during deploy, it will receive an
    `$ENVIRONMENT` environment variable. `cz/environment` can perform any
    platform- or language-specific setup required based on the environment. For
    instance, for Rails apps, we ensure that the `$RAILS_ENV` is the same as the
    incoming `$ENVIRONMENT` value.
* `health-check`, once fully implemented, will be executed automatically inside
    your app's containers in order to assess their health, for reporting by
    `docker ps`. Depending on the role your app was started in, the check might
    vary. Be sure not to do anything too resource-consuming in this script, as
    it will be called frequently.
* `idle` is just responsible for ensuring a container remains running long
    enough for our deployment process to copy your app's vault contents into the
    volume we create for it. You shouldn't have to modify this.
* `post-deploy` is run after your application has been successfully started on
    all nodes. If you have anything you'd like to perform after a successful
    start, it can go here.
* `pre-deploy` runs just before we proceed with deploying your app on each
    node. If it exits with nonzero (that is, error) status, it will abort the
    deploy process before anything has changed. It should follow, then, that
    this script should not, itself, try to change anything. It might, however,
    run a simple system check to ensure all application artifacts are present
    and working.
* `run-once` is run (as its name would suggest) only once per deployment. Its
    job is to take care of migrating any application state to support the new
    version of the application. If it fails, the deployment is stopped, but
    troubleshooting will be needed to determine the course of action required
    to roll back any state changes. Take special care to ensure that your code
    is as resilient as possible to state migrations, and that any state
    migrations don't render the previous version of code inoperable.
* `start` is where the work of actually starting your application occurs.
    Depending on the role in which your application is being started, this
    script will `exec` the appropriate process.

#### A word about application roles

In the documentation prior to this, you may have noticed that we mentioned the
term "role" a few times. In the context of a `cz`-managed app, the "role" is the
mode in which your app's code will be launched. For instance, a typical Rails
application might require background job processing. This is typically performed
by something like Sidekiq. In a traditional server- or VM-based deployment,
multiple processes will be launched or restarted on the server when the
deployment artifacts are received. With Docker, this translates to multiple
containers being launched.

Roles are defined for deployed applications by the key names under an
evironment's `deploy.yml` stanza, and for development-mode apps by setting the
`ROLE` environment variable in `docker-compose.yml`. They can be used by many of
the deploy-related hooks in the `cz` directory, but by default are only used by
the `start` and `health-check` scripts. These scripts determine the process to
start based on the role the container is being started in. So, where a
traditional server-based deploy would start an app server and worker processes,
a Docker-based deploy will start two containers, one with `ROLE` app, and one
with `ROLE` workers.

It's important to remember that roles still refer to your own application code.
These are not (quite) like Docker Compose services, in that they aren't pointing
at different images. They're all running in your app's image -- they just start
a different _part_ of your app.

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

We might choose to add the following to our `config/application.rb`:

```ruby
# You could also choose to initialize this in an initializer, but then you'll
# need to update certain rake tasks to load the environment. We choose to do
# this here because the CZ Config is a top-level app concern.
Vault = CZ::Config.load(File.expand_path('../../vault', __FILE__))
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
  Rails.root + 'config/files',
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
# directory tree (some of it might actually _be_ a directory tree, after all)
AppConfig[:key]                # => "value" (everyone loves symbols)
AppConfig['subdirectory/file'] # => "subdirectory file contents"
# But even if it's not a directory tree...
AppConfig['key_with_subkey/subkey'] # => "subkey value"

# If you've got a file in your config, and you're interested in its path, not
# its content...
AppConfig.subdirectory.file.path # Relative to the current working directory
# => #<Pathname:test/fixtures/directory/subdirectory/file>
AppConfig.subdirectory.file.absolute_path # Absolute path
# => #<Pathname:/Users/.../test/fixtures/directory/subdirectory/file>

# Under normal circumstances, a `CZ::FileProxy` object (which is what you get
# when you access a key that contains a file) should be interchangeable with the
# file's content. However, if you find you really need to force-load the
# content, you can ask for it explicitly:
AppConfig.subdirectory.file.content
# => 'file contents'

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

#### Alpine preferred, Slim permitted

Wherever possible, images should be based on an Alpine Linux image. So, if
you're writing a Ruby app, your Dockerfiles should start with:

```Dockerfile
FROM ruby:<your-version>-alpine
```

Alpine is far smaller than other distros, which makes it perfect for containers.
The only notable exception is when your app needs to be able to build something
with an unfortunate hard dependency on `glibc`, which occasionally does happen.
Alpine uses `musl` libc, which is mostly compatible but occasionally falls
short. As Alpine becomes more popular, however, developers are increasingly
working to ensure their code builds against `musl`.

#### Docker Compose service names should match role names

While it's impossible to force Docker Compose to honor the shorter syntax that
`deploy.yml` supports, it does have a key that roughly corresponds to our
meaning of "role" -- so, your app's "app" role should have a service entry named
"app" in `docker-compose.yml` that defines `ROLE: app` in its `environment:`
stanza.

#### Build native extensions

To catch more potential issues at build time instead of deploy time, you should
configure your language environment of choice to build any native extensions.
This does not apply to dependencies installed via your distribution's package
manager, but for things like RubyGems, Python packages, and so on.
`BUNDLE_FORCE_RUBY_PLATFORM=1` accomplishes this for Ruby with Bundler > 1.14,
and is configured in the default Dockerfiles.

#### The "app" role

All apps *MUST* have an "app" role defined. **If your app only needs one
container, that container is "app".** The "app" role should be considered the
"primary" container of the app, and it is the default role started by commands
like `cz console`. If your app has a web interface, this is probably its "app"
role.

#### Store non-secret configuration in the environment, or in plain files

It can be tempting to throw entire YAML configuration files into your app's
vault, since it separates configuration information out by environment. However,
the vault is primarily for secret information, and unless that YAML file is
almost completely full of secrets, it would be far better for the structure of
this configuration to be visible to a developer with minimal effort. Consider
the Rails `database.yml`, for instance. While it's perfectly workable to store
an environment-specific version of that file in your vault for each environment,
and simply symlink the `config/database.yml` to `../vault/database_config` or
similar, devs lose visibility to the structure of that configuration that would
be visible using more traditional means.

Consider, for instance, the improved readability of a `database.yml` like the
following:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: <%= ENV.fetch('DB_HOST', 'localhost') %>
  username: <%= ENV.fetch('DB_USER', ENV['USER']) %>
  password: <%= Vault[:database_password, default: ''] %>

development:
  <<: *default
  database: app_development

test:
  <<: *default
  database: app_test

production:
  <<: *default
  database: app_production

staging:
  <<: *default
  database: app_staging
```

This makes it clear what keys are supplied in each environment, and allows the
injection of non-secret configuration information via environment variables or,
of course, `CZ::Config` objects. And it makes it clear, in this case, that the
app's vault will in fact contain a string named `database_password` with an
appropriate password for environments which require one.

And, in true [12-factor](https://12factor.net/config) fashion, the
deploy-specific bits are nicely factored out into independently-changeable
values.

If you have a giant chunk of non-secret configuration, don't forget you can
simply do...

**config/application.rb**
```ruby
AppConfig = CZ::Config.load("config/application.#{ENV['RAILS_ENV']}.yml")
```

#### Store secret configuration only in the vault

If it wasn't clear from the above, the corollary to "store non-secret config
here" is "store secret config somewhere else". That "somewhere else" is the
vault.  Note that you can store information ranging from a 16-character
database password to a several-kilobyte certificate file with equal simplicity.
Where possible, favor smaller secrets, and mark them as secret by the way you
expose them to your application. For instance, consider always loading your
vault contents into a `Vault` constant, and accessing secrets from there.

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
