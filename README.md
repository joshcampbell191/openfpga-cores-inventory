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

## API Usage
openFPGA Cores Inventory provides a read-only API for developers.

### Get list of cores
#### Request
`GET /api/v0/analogue-pocket/cores.json`

    curl -i -H 'Accept: application/json' https://joshcampbell191.github.io/openfpga-cores-inventory/api/v0/analogue-pocket/cores.json

#### Response

    HTTP/1.1 200 OK
    Etag: 170e0e5-1877-632ceaa7
    Content-Type: application/json; charset=utf-8
    Content-Length: 6263
    Last-Modified: Thu, 22 Sep 2022 23:07:19 GMT
    Cache-Control: private, max-age=0, proxy-revalidate, no-store, no-cache, must-revalidate
    Server: WEBrick/1.7.0 (Ruby/3.0.2/2021-07-07)
    Date: Thu, 22 Sep 2022 23:09:25 GMT
    Connection: close

    [
        {
            "repo": {
                "user": "Mazamars312",
                "project": "Analogue_Pocket_Neogeo"
            },
            "name": "Mazamars312.NeoGeo",
            "platform": "Neo Geo",
            "assets": {
                "location": "Assets/ng/common",
                "files": [
                    {
                        "file_name": "uni-bios_1_0.rom",
                        "url": "https://archive.org/download/MAME_2003-Plus_Reference_Set_2018/roms/bakatono.zip/uni-bios_1_0.rom"
                    }
                ]
            }
        }
    ]

## Adding a new core
To add a new core, you will need to edit the `_data/cores.yml` file. At a minimum, you must add:

```yaml
- user: agg23
  cores:
    - repo: analogue-arduboy
      display_name: Arduboy for Analogue Pocket
```

The top level `user` key is the developer's GitHub username and `cores` is a list of cores by that developer. `repo` is the GitHub repository name of the core and `display_name` is the name that will be used to list the core in the [cores table](https://joshcampbell191.github.io/openfpga-cores-inventory/analogue-pocket.html).

There are many other optional keys that are needed by some specific cores for application developers. More documentation will be added at a later date.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)
