# SLAPI Adapter - Slack

Adapter that enables SLAPI Bot to utilize the Slack Chat Service
## Prerequisites
-   Docker 1.10 or later

## Usage

### Config
Config required SLAPI config file `bot.yml`

```yaml
# Adapter Settings
adapter:
  service: slack # Enables option alternative adapters
  config:
    token:
    user_agent: # User-agent, defaults to Slack Ruby Client/version.
    proxy: # Optional HTTP proxy.
    ca_path: # Optional SSL certificates path.
    ca_file: # Optional SSL certificates file.
    endpoint: # Slack endpoint, default is https://slack.com/api.
    logger: # Optional Logger instance that logs HTTP requests.
 ```
## Testing

## How to Contribute

### External Contributors

-   Fork the repo on GitHub
-   Clone the project to your own machine
-   Commit changes to your own branch
-   Push your work back up to your fork
-   Submit a Pull Request so that we can review your changes

**NOTE**: Be sure to merge the latest from "upstream" before making a pull request!

### Internal Contributors

-   Clone the project to your own machine
-   Create a new branch from master
-   Commit changes to your own branch
-   Push your work back up to your branch
-   Submit a Pull Request so the changes can be reviewed

**NOTE**: Be sure to merge the latest from "upstream" before making a pull request!