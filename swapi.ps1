$resourceTypes = @(
     'people', 
     'planets',
     'films',
     'species',
     'starships',
     'vehicles'
)
$resourcemap = @{
     'people' = 'person' 
     'planets' = 'planet'
     'films' = 'film'
     'species' = 'race'
     'starships' = 'starship'
     'vehicles' = 'vehicle'
}

# Private Functions
function get_one($resource, $id) {
    if (($id -isnot [int]) -or ($resourceTypes -notcontains $resource)){
        $item = new-errorobject $resource $id
        $extraDetails = "ID must be an integer`nResource must be one of: $([string]::join(",",$resourceTypes))"
        add-member -inputobject $item -membertype noteproperty -name "ExtraDetails" -value $extraDetails
    } else {
        try { $item = (invoke-webrequest http://swapi.co/api/$resource/$id/).content | convertfrom-json }
        catch { $item = new-errorobject $resource $id }
        return $item
        }
}

function new-errorobject ($resource, $id){
    $item = new-object system.object
    $displaystring = "No record of type $resource was found for id:$id"
    add-member -inputobject $item -membertype noteproperty -name "ResourceTypeRequested" -value $resource
    add-member -inputobject $item -membertype noteproperty -name "id" -value $id
    add-member -inputobject $item -membertype noteproperty -name "Description" -value $displaystring 
    return $item
}

function pad-CRLFLine ($line,$padlength, $offset){
    $length = $Line.length
    if ($length -eq $padlength) {
        " $($Line.insert(($padlength - 1)," "))" 
    } else {
        " " + $line.insert(($length - $offset), (" " * ($offset + ($padlength - $length))))
    }
}

# Public Functions
function get-all($resource) {
    $returnvals = @()
    $count = ((invoke-webrequest http://swapi.co/api/$resource).content | convertfrom-json).count
    $pagelimit = [math]::ceiling($count / 10)
    1..$pagelimit | % {$returnvals += ((invoke-webrequest http://swapi.co/api/$resource/?page=$_).content | convertfrom-json).results }
    return $returnvals
    }

function get-person($id){
     get_one people $id 
}

function get-planet($id){
    get_one planets $id
}

function get-film($id){
    get_one films $id
}

function get-species($id){
    get_one species $id
}

function get-race($id){
    get_one species $id
}

function get-starship($id){
    get_one starships $id
}

function get-vehicle($id){
    get_one vehicles $id
}

function get-resourcetype ($object) {

    $resourcemap[$object.url.split('/')[4]]
}

function play-crawl ($film){
    $crawl = $film.opening_crawl.split("`n")
    $max = ($crawl | % { $_.length } | measure-object -maximum).maximum  
    $offset = 1
    for ($i = 0; $i -lt $crawl.length; $i++) {
        $line = $crawl[$i]
        if ($i -eq ($crawl.length - 1)) {$offset = 0} 
                if ($line.length -gt 1){
            write-host -foregroundcolor yellow -BackgroundColor black (pad-CRLFLine $line $max $offset)
            start-sleep -milliseconds 600
        } else {
            write-host $line
            start-sleep -milliseconds 250
        }
    }  
}
