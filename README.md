# PadawAPI a powershell wrapper for Star Wars API

## About
a powershell wrapper for connecting to the [Star Wars API](https://swapi.co/).

## Requires
- [powershell](https://github.com/PowerShell/PowerShell) for windows, mac or linux
- internet connectivity
  - if behind a proxy then powershell may need to pass credentials.... sometimes having a browser open and connected will enable PS to reuse established connection

## How to use
Import the module using `import-module PadawAPI.psd1`  
The listed functions will be available for use

### Functions
- `get-all ($resource)` get all instances of type $resource
- `get-person ($id)` get one instance of person by numeric id
- `get-planet ($id)`get one instance of planet by numeric id
- `get-film ($id)` get one instance of film by numeric id
- `get-species ($id)` get one instance of species by numeric id
- `get-race ($id)` get one instance of species by numeric id
- `get-starship ($id)` get one instance of starship by numeric id
- `get-vehicle ($id)` get one instance of vehicle by numeric id
- `play-crawl ($film)` play the opening crawl of a film instance
- `get-resourcetype ($object)` get the type of resource object

## License
PadawAPI is available under the MIT license. See the LICENSE file for more info.
