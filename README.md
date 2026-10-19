# devcontainer

Development environment for the _TailoringeXpert_ (Demo-)platform.

## Configuration / User-specific customisations

The configuration for a user essentially needs to be carried out for

- repositories
- GPG
- Maven

There are three scripts for this purpose

- **[repos.sh]** Cloning and configuring the _git_ repositories
- **[gpgkeys.sh]** Installation and testing of private **gpg** keys
- **[maven.sh]** Generation of the Maven _settings.xml_

which can be found in the bin directory and in the user’s search path.

A global configuration file is used to run the scripts. 
When the container is started for the first time, this file can be found in the directory

> ~/workspace/.vscode/environment.json

and must be customised to suit the user’s requirements.

**This file is NOT overwritten by the system!**

## environment.json configuration file

### repositories

The _repositories_ element contains one or more _git repositories_ that should be included in the workspace.

``` json
  "repositories": [
    {
      "name": "dependencies",
      "url": "https://github.com/tailoringexpert/dependencies.git",
      "username": "",
      "email": "",
      "sign": true,
      "signkey": ""
    }
  ]
```

- **[name]** the name of the directory into which the repository is to be cloned
- **[url]**  the _clone_ URL
- **[username]** the name to be displayed for commits
- **[email]** the email address to be used for the commit
- **[sign]** whether the commit should be signed
- **[signkey]** the key (ID) to be used for signing

### gitcredentials

The gitcredentials element contains one or more sets of credentials required for the project domains.

``` json
  "gitcredentials": [
    {
      "username": "",
      "password": "",
      "domain": "github.com"
    }
  ]
  ```

  - **[username]** the username required to access the repository
  - **[password]** usually the token required for access
  - **[domain]** the domain where the credentials are valid

### gpgkeys

The `gpgkeys` element contains one or more GPG keys to be used for signing commits.

```json
    "gpgkeys": [
    {
      "key": "",
      "passphrase": "",
      "email": ""
    }
  ]
```
  - **[key]** Key ID
  - **[passphrase]** Key passphrase
  - **[email]** Email address associated with the key

### maven

```json
  "maven": {
    "server": {
      "id": "github.com",
      "token": ""
    },
    "sonar": {
      "activate": "false",
      "url": "",
      "token": ""
    }
  }
  ``` 
  - **[server.id]** ID of the (Maven package) server
  - **[server.token]** Access token for the server
  - **[sonar.activate]** Indicates whether Sonar checks should be enabled
  - **[sonar.url]** URL where the Sonar service is available. As no DLR server is known, a private server is used; therefore, no plaintext value is provided
  - **[sonar.token]** Token for accessing Sonar
