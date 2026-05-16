# Installation

## Requirements

- Ruby >= 3.2
- The [sqa](https://github.com/MadBomber/sqa) gem (provides TA-Lib bindings)
- An Anthropic API key **or** an OpenAI API key

!!! note "TA-Lib dependency"
    SQA requires TA-Lib to be installed on your system. On macOS: `brew install ta-lib`.
    On Ubuntu/Debian: `apt-get install libta-lib-dev`.

## Install the gem

=== "Bundler"

    Add to your `Gemfile`:

    ```ruby
    gem "sqa-advisor"
    ```

    Then run:

    ```bash
    bundle install
    ```

=== "Direct"

    ```bash
    gem install sqa-advisor
    ```

=== "From source"

    ```bash
    git clone https://github.com/MadBomber/sqa-advisor
    cd sqa-advisor
    bundle install
    ```

## Verify the installation

```bash
sqa-advisor --version   # if installed as a gem
# or
bundle exec sqa-advisor # from source
```

## Next step

[Configure your API keys →](configuration.md)
