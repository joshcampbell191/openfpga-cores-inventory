# openFPGA Cores Inventory
openFPGA Cores Inventory is the premier destination for keeping track of cores built with [openFPGA](https://www.analogue.co/developer).

## Installation
You will need to install [Ruby](https://www.ruby-lang.org/en/documentation/installation/), then run the following command in the root of the project:

```bash
$ bundle install
```

## Running the app
In the project root, run the following command:

```bash
$ bundle exec jekyll serve
```

Then navigate to `http://localhost:4000/`

## API usage
openFPGA Cores Inventory provides a read-only API for developers.

### Cores

#### Getting the list of cores
Returns a list of all available cores for the Analogue Pocket.

```
GET https://joshcampbell191.github.io/openfpga-cores-inventory/api/v0/analogue-pocket/cores.json
```

Example request:

```
GET /api/v0/analogue-pocket/cores.json HTTP/1.1
Host: https://joshcampbell191.github.io
Content-Type: application/json
Accept: application/json
Accept-Charset: utf-8
```

The response is a list of core objects. The response array is wrapped in a data envelope.

Example response:

```
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{
  "data": [
    {
      "identifier": "ericlewis.Asteroids",
      "platform": "Asteroids",
      "version": "0.9.1",
      "release_date": "2022-09-09",
      "repository": {
        "platform": "github",
        "owner": "ericlewis",
        "name": "openfpga-asteroids"
      },
      "assets": [
        {
          "platform": "asteroids",
          "filename": "asteroid.rom",
          "extensions": [
            "rom"
          ],
          "core_specific": true
        }
      ]
    }
  ]
}
```

Where a core object is:

| Field        | Type         | Description                                    |
| ------------ | ------------ | ---------------------------------------------- |
| identifier   | string       | The core's unique identifier.                  |
| platform     | string       | The name of the core's game platform.          |
| version      | string       | The core's current version number.             |
| release_date | string       | The date of the core's latest release.         |
| repository   | object       | An object describing where the core is hosted. |
| assets       | object array | A list asset objects.                          |

Where a repository object is:

| Field    | Type   | Description                                                                     |
| -------- | ------ | ------------------------------------------------------------------------------- |
| platform | enum   | The website where the repo is located. Currently, this always returns `github`. |
| owner    | string | The core developer's GitHub username.                                           |
| name     | string | The core's GitHub repository name.                                              |

Where an asset object is:

| Field         | Type    | Required | Description                                                                                                                                                                               |
| ------------- | ------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| platform      | string  | true     | The core's platform, specified by its `platform.json` file.                                                                                                                               |
| filename      | string  | false    | The name of the asset file.                                                                                                                                                               |
| extensions    | array   | false    | A list of valid file extensions for the asset.                                                                                                                                            |
| core_specific | boolean | false    | Indicates if an asset is specific to this core only. If so, it should be placed in `Assets/<platform>/<identifier>`. Otherwise, the asset should be placed in `Assets/<platform>/common`. |

Possible errors:

| Error code    | Description                                  |
| ------------- | -------------------------------------------- |
| 403 Forbidden | The GitHub API rate limit has been exceeded. |

## Adding a new core
To add a new core, you will need to edit the `_data/repos.yml` file. You must add the following fields:

```yaml
- username: ericlewis
  cores:
    - display_name: Asteroids for Analogue Pocket
      repository: openfpga-asteroids
```

- `username` is the core author's GitHub username. It can be found after the first `/` in the core's URL (e.g. `https://github.com/ericlewis/openfpga-asteroids` -> `ericlewis`).
- `display_name` is used in the `Name` column of the [cores table](https://joshcampbell191.github.io/openfpga-cores-inventory/analogue-pocket.html). A good value for this is usually the name used at the top of the core's `README.md` file.
- `repository` is the core's GitHub repository name. It can be found after the last `/` in the core's URL (e.g. `https://github.com/ericlewis/openfpga-asteroids` -> `openfpga-asteroids`).

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)
