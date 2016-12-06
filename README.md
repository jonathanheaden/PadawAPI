# PadawAPI a powershell wrapper for Star Wars API
## About
a powershell wrapper for connecting to the Star Wars API.
## Requires
- internet connectivity
  - if behind a proxy then powershell may need to pass credentials.... sometimes having a browser open and connected will enable PS to piggyback on the established connection
## How to use
Import the module using `import-module SWAPI.ps1`  
The listed functions will be available for use

### Functions
- `get-all ($resource)`
- `get-person ($id)`
- `get-planet ($id)`
- `get-film ($id)`
- `get-species ($id)`
- `get-race ($id)`
- `get-starship ($id)`
- `get-vehicle ($id)`
- `play-crawl ($film)`
- `get-resourcetype ($object)`

## License
PadawAPI is available under the MIT license. See the LICENSE file for more info.
