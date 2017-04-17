# `cz` Usage Scenarios

## Adding `cz` to a new (Ruby) application

1. Ensure you have the latest `cz` gem installed:

    ```sh
    $ gem install cz -s http://gems.czops.net:9292
    $ cz version
    ```

    Also, add it to your Gemfile, if you want to make use of features it
    provides for configuration.

2. Initialize for your application. From the project root, for a Rails app that
    should run in an alpine container:

    ```sh
    $ cz init
    ```

    For one that needs to run in slim (if you don't know, try alpine first, and
    switch to slim if your app can't build/link properly -- or, if you're using
    the `magic-bus` gem, just go with slim from the start, because
    [Google hates us](https://github.com/grpc/grpc/issues/8899)):
    ```sh
    $ cz init rails-slim
    ```

3. Examine the system-level dependencies set up near the top of
    `Dockerfile.dev`, removing any your app doesn't need in order to build, and
    adding any that are missing.

4. Similarly, examine the system-level dependencies set up near the top of
    `Dockerfile.deploy`, removing any your app doesn't need in order to run, and
    adding any that are missing.

5. Don't mess with anything else in the Dockerfiles. Seriously. Not at first,
    anyway. It is highly unlikely you'll need to change anything else to get
    your app building. Start small and only tweak those files when you are
    really sure you need to.

6. Add any developers (with their @carezone.com addresses) that should be able
    to work on and/or deploy this app to `cz.yml`. These are the devs who'll be
    able to work with any application secrets you store in the app's vault.

7. While you're there, add the hostnames of any staging or deploy servers
    assigned to your app, if you know them.

8. Examine the sample `cz/start` and `cz/health-check` scripts. Determine what
    roles your app will run in and add/remove roles, ensuring you have at least
    an `app` role defined. Be sure to `exec` your process for each role in
    `cz/start`!

9. Load your app's vault contents in `config/application.rb`:

    ```ruby
    Bundler.require(*Rails.groups)

    root = Pathname(File.expand_path('../..', __FILE__))

    Vault = CZ::Config.load(root + 'vault')
    ```

10. Add your first secrets to the vault, the Rails `secret_key_base` for staging
    and production:

    ```sh
    $ rails secret | xargs echo -n | cz vault set staging secret_key_base
    $ rails secret | xargs echo -n | cz vault set production secret_key_base
    ```

    Then use them in `config/secrets.rb`:

    ```yaml
    production:
      secret_key_base: <%= Vault[:secret_key_base, default: nil] %>

    staging:
      secret_key_base: <%= Vault[:secret_key_base, default: nil] %>
    ```

11. Similarly, add staging and production database passwords to the vault:

    ```sh
    cz vault set staging database_password "staging database password"
    cz vault set production database_password "production database password"
    ```

    Then, use them in `config/database.yml`. A minimal database config that
    loads passwords from the vault and the rest from its environment might look
    like this:

    ```yaml
    default: &default
      adapter: postgresql
      encoding: unicode
      pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
      host: <%= ENV.fetch("DB_HOST", "localhost") %>
      username: <%= ENV.fetch("DB_USER", ENV["USER"]) %>
      password: <%= Vault[:database_password, default: nil] %>

    development:
      <<: *default
      database: your_app_name_development

    test:
      <<: *default
      database: your_app_name_test

    production:
      <<: *default
      database: your_app_name_production

    staging:
      <<: *default
      database: your_app_name_staging
    ```

12. Ensure you're serving static assets in production and staging by updating
    `config/environments/production.rb`:

    ```ruby
    config.public_file_server.enabled = true
    ```

    Then, create a `config/environments/staging.rb` with the following contents:

    ```ruby
    require_relative 'production'

    Rails.application.configure do
      # Add anything here that you need to configure differently for staging.
    end
    ```

13. Tell us how to launch your app when you deploy by updating `deploy.yml` with
    your app's requirements.
