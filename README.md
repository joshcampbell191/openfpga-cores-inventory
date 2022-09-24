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
      "repo": {
        "user": "spiritualized1997",
        "project": "openFPGA-GB-GBC"
      },
      "identifier": "Spiritualized.GBC",
      "platform": "Gameboy/Gameboy Color",
      "assets": {
        "location": "Assets/gbc/common/",
        "files": [
          {
            "file_name": "dmg_bios.bin",
            "url": "https://archive.org/download/mister-console-bios-pack_theypsilon/Gameboy.zip/GB_boot_ROM.gb",
            "override_location: "Assets/gb/common/"
          },
          ...
        ]
      }
    },
    ...
  ]
}
```

Where a core object is:

| Field             | Type   | Description                                                                |
| ------------------|--------|----------------------------------------------------------------------------|
| repo              | object | An object containing the developer and repo name.                          |
| identifier        | string | The core's unique identifier.                                              |
| platform          | string | The name of the core's game platform.                                      |
| assets            | object | An object containing a description of additional asset files for the core. |

Where a repo object is:

| Field             | Type   | Description                                                               |
| ------------------|--------|---------------------------------------------------------------------------|
| host              | enum   | The website that hosts the repo. Currently, this always returns "github". |
| user              | string | The core developer's GitHub username.                                     |
| project           | string | The core's GitHub repository name.                                        |

Where an asset object is:

| Field             | Type         | Description                                                     |
| ------------------|--------------|-----------------------------------------------------------------|
| location          | string       | The path on the SD card where the core's assets must be placed. |
| files             | object array | A list of file objects.                                         |

Where a file object is:

| Field             | Type   | Description                                                                                                         |
| ------------------|--------|---------------------------------------------------------------------------------------------------------------------|
| file_name         | string | The name the file must use in the core's Assets directory.                                                          |
| url               | string | The URL where the file is located.                                                                                  |
| override_location | string | The path on the SD card where this file should be placed. This overrides the `location` stored in the asset object. |

Possible errors:

| Error code    | Description                                  |
| --------------|----------------------------------------------|
| 403 Forbidden | The GitHub API rate limit has been exceeded. |

## Adding a new core
To add a new core, you will need to edit the `_data/cores.yml` file. At a minimum, you must add the fields marked `<required>`:

```yaml
- username: spiritualized1997              #<required>
  cores:                                   #<required>
    - repo: openFPGA-GB-GBC                #<required>
      display_name: Spiritualized GB & GBC #<required>
      identifier: Spiritualized.GBC        #<required>
      platform: Gameboy/Gameboy Color      #<required>
      assets:
        location: Assets/gbc/common/
        files:
        - file_name: gbc_bios.bin
          url: https://archive.org/download/mister-console-bios-pack_theypsilon/Gameboy.zip/GBC_boot_ROM.gb
        - file_name: dmg_bios.bin
          url: https://archive.org/download/mister-console-bios-pack_theypsilon/Gameboy.zip/GB_boot_ROM.gb
          override_location: Assets/gb/common/
```

Information on what these fields mean can be found in the [API description](#getting-the-list-of-cores). There is one additional field `display_name` that is used in the [cores table](https://joshcampbell191.github.io/openfpga-cores-inventory/analogue-pocket.html).

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)
