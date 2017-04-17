# CHANGELOG

All notable changes to `cz` will be documented in this file, and the format is
based on [Keep a Changelog](http://keepachangelog.com/).

H2 headers indicate the release version, or "Unreleased" for holding changes
that we'll apply a version to once we tag it.

H3 headers are one of:

* `Added` for new features.
* `Changed` for changes in existing functionality.
* `Deprecated` for once-stable features removed in upcoming releases.
* `Removed` for deprecated features removed in this release.
* `Fixed` for any bug fixes.
* `Security` to invite users to upgrade in case of vulnerabilities.

Be sure to add a reference to the diffs in the footer, for the named links used
on versions.

## [Unreleased]

Nothing yet.

## [0.3.9]

### Fixed

* Previously, we were seeing two large layers on every new deploy, instead of
    one. This is because we were `chown`ing the files we copied in, including
    the large `vendor` directory. Instead, we'll now ensure `vendor` is
    world-readable and let it alone during `chown`.

## [0.3.8]

### Added

* `cz start` command no longer exits with a stacktrace when you stop it with
    CTRL-C. We can't fix the issues that `docker-compose` itself has with
    occasionally refusing to do the right thing on a CTRL-C, but we can fix our
    own problems.
* `cz bootstrap` now unpacks the development vault, and trying to unpack a
    vault that you haven't got permissions to unpack will give more helpful
    output.

### Changed

* We've reduced the number of anchors in the default `deploy.yml` file. Fewer
    anchors should result in smoother sailing. ⛵️
* We've replaced remaining calls to `rake` with `rails` for more Rails-5-ness,
    and removed the unnecessary comments re: version in generated files.

### Fixed

* Sample `cz/start` was calling `bin/sidekiq` but `sidekiq` was necessary, since
    the binstubs get installed to a directory in the PATH.
* During deploy, if the server returned an error, we weren't echoing it to the
    terminal, resulting in an annoying "ssh to the server to see what happened"
    step. Sorry about that.

## [0.3.7]

### Fixed

* Inadverntently called content's private method `respond_to_missing?` in
    `CZ::FileProxy`'s implementation of `respond_to_missing?`. This method is
    hit during things like implicit conversion to string (`to_str`) and was
    triggering an error when setting the HMAC key in MagicBus, for instance.

## [0.3.6]

### Fixed

* `CZ::Config` was not correctly returning a default when traversing past an
    existing key with a nonexistent subkey.
* When running `cz console` locally, a different environment would be present
    depending on whether you were `exec`-ing inside an running container or
    you were running a new one, because the entrypoint is skipped in the case
    of the former.

## [0.3.5]

### Added

* Skip prompting for overwrite when files are identical, and display diffs when
    not, during `cz init`.

## [0.3.4]

### Added

* Improved error output when invalid commands are issued.

## [0.3.3]

### Added

* Default Dockerfiles now make use of `set -ex` to exit failing builds early and
    echo commands as they're being run.
* Default .dockerignores now ignore the `.git` directory.
* When invalid commands are provided, more helpful output is generated.

## [0.3.2]

### Added

* If for some reason you're using a file in a `CZ::Config` object in a way that
    simply doesn't play nicely with a `CZ::FileProxy`, you can get the content
    directly with the `content` method. You generally shouldn't need this, but
    hey, it's nice to have. Just in case.

### Changed

* Inspecting a file in a `CZ::Config` will properly indicate its status as a
    `CZ::FileProxy` object.

## [0.3.1]

### Added

* A `rails-slim` template has been added. `cz init rails-slim` will add/update
    template files that work with a slim image.

### Changed

* The default `docker-compose` now makes use of the `-alpine` variants of
    PostgreSQL and Redis images.

### Fixed

* Noisy errors during `cz bootstrap` on slim images should be silenced.

## [0.3.0]

### Added

* For `CZ::Config` values that are files (from `load`-ing a directory), it's now
    possible to access the file's path and absolute path, with `path` and
    `absolute_path`, accordingly.

## [0.2.2]

### Added

* New `bootstrap` command to build image, app, and run any one-time setup added
    to the `cz/bootstrap` script after cloning a repository.
* New `console` command will run `cz/console` in your existing, running
    docker-compose container, or start a new one if needed. Specify an alternate
    role (based on the ones from your app's image, of course) to start the
    console in its corresponding container (as defined in your
    `docker-compose.yml` file).
* New `start` and `stop` commands, which are simply wrappers around their
    corresponding `docker-compose` `up` and `down` equivalents.
* The default `cz/bootstrap` script now illustrates how to wait for PostgreSQL
    to come online before setting up the app.

### Changed

* We've eliminated the requirement to use `forward_term` to handle cleanly
    shutting down your app, since plain old `exec` works now. Future runs of
    `cz init` will no longer create a `forward_term` file, nor use it in their
    `start` and `idle` scripts. This file can be safely deleted after updating.
* We're now illustrating the use of environment variables for database and
    Redis non-secret configuration in `docker-compose.yml` and `deploy.yml`.

## [0.2.1]

### Changed

* `gpg push` will only push the active user's public key

## [0.2.0]

### Added

* Started maintaining a changelog
* Added `gpg push` and `gpg pull` commands. These allow synchronization of our
    public GPG keys with one another, for use in various encryption-related
    tasks (including vault encryption).

### Changed

* Bundler has been updated to 1.14.6 in the default Dockerfile.
* The `BUNDLE_FORCE_RUBY_PLATFORM` is now being set in the default Dockerfile,
    which will cause gems to always build from source. This eliminates a number
    of issues that can be encountered due to subtle glibc/musl libc differences.

## [0.1.6]

### Added

* Helpful information and some default developers are now included in `cz.yml`,
    to hopefully increase the bus factor of our dockerized apps.

## [0.1.5]

### Fixed

* Updated `cz/clean` to run `bin/rake assets:clobber` _before_ cleaning up all
    vendored gems. Turns out that if you're gonna run scripts pointing at your
    vendored gems, you shouldn't delete them first. Who knew?

## [0.1.4]

### Fixed

* Shell script conditionals were not working in slim, and have been updated to
    work across more Linux versions.

## [0.1.3]

### Added

* Geminabox releases can now be pushed via the standard `rake release` command.
* The `push` command was added, to push an image to the remote registry. This
    will not affect the flow of `cz build <env>` -> `cz deploy <env>`, since a
    deploy will push if it hasn't been done yet.
* Restored disable functionality related to checking your current git status.
    Non-deployable builds can stll be generated from a dirty working tree, but
    builds that are for deployable environments must have a clean working tree
    and be pushed to origin.

### Changed

* `cz build` can now be run without parameters to build a development image,
    along with the app code.
* Deployable environments are now inferred from the environments listed in an
    app's `cz.yml` file. When building for one of these environments, the
    `cz/build` script can determine whether or not to generate artifacts for
    copying to an image, or running locally via a volume mount. The script will
    output which mode is being used during build.

### Fixed

* Commands being executed by `cz` were not displaying results as they ran, which
    made determining progress vs hung status somewhat tricky.

## [0.1.2]

### Added

* Releases can now be pushed to geminabox via `rake inabox:release`

### Changed

* The `cz/environment` script is now the entrypoint for all containers started
    from images. This should help clarify the behavior of containers when
    started using `/bin/sh` or otherwise skipping the normal cz initialization.

## [0.1.1]

### Added

* A comment is now in the header of `vault.yml` to clarify its auto-generated
    nature.

### Changed

* `vault get` no longer adds a newline to all values fetched from the vault.
    This enables piping of `vault get` to `vault set` to copy secrets across
    environments.

### Fixed

* The default .dockerignore no longer allows files it should have been ignoring.

[Unreleased]: https://github.com/carezone/cz/compare/v0.3.9...HEAD
[0.3.9]: https://github.com/carezone/cz/compare/v0.3.8...v0.3.9
[0.3.8]: https://github.com/carezone/cz/compare/v0.3.7...v0.3.8
[0.3.7]: https://github.com/carezone/cz/compare/v0.3.6...v0.3.7
[0.3.6]: https://github.com/carezone/cz/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/carezone/cz/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/carezone/cz/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/carezone/cz/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/carezone/cz/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/carezone/cz/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/carezone/cz/compare/v0.2.2...v0.3.0
[0.2.2]: https://github.com/carezone/cz/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/carezone/cz/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/carezone/cz/compare/v0.1.6...v0.2.0
[0.1.6]: https://github.com/carezone/cz/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/carezone/cz/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/carezone/cz/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/carezone/cz/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/carezone/cz/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/carezone/cz/compare/v0.1.0...v0.1.1
