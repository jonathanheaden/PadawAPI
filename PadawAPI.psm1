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
        }
        return $item
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

function get-person($id, $addMethods = $true){
    $person = get_one people $id 
    if ($addMethods) {
        add-member -InputObject $film -MemberType noteproperty -name FilmList -value $false
        add-member -InputObject $person -MemberType ScriptMethod -name FilmNames -Value {
            if ($this.FilmList) {
                    $this.FilmList
                } else { 
                    $this.FilmList = ( $this.films | % {
                        $x = [int]$_.split("/")[5]
                        (get-film $x $false).name
                        })
                    $this.FilmList
            }
        }
    }
    return $person
}

function get-planet($id, $addMethods = $true){
    $planet = get_one planets $id
    if ($addMethods) {
        add-member -InputObject $film -MemberType noteproperty -name PeopleList -value $false
        add-member -InputObject $planet -MemberType ScriptMethod -name PeopleNames -Value {
            if ($this.PeopleList) {
                    $this.PeopleList
                } else { 
                    $this.PeopleList = ( $this.residents | % {
                        $x = [int]$_.split("/")[5]
                        (get-person $x $false).name
                        })
                    $this.PeopleList
            }
        }
    }
    return $planet
}

function get-film($id, $addMethods = $true){
    $film = get_one films $id
    if ($addMethods) {
        add-member -InputObject $film -MemberType ScriptMethod -name PlayOpeningCrawl -Value {
            play-crawl $this
        }
        add-member -InputObject $film -MemberType noteproperty -name CharacterList -value $false
        add-member -InputObject $film -MemberType ScriptMethod -name CharacterNames -Value {
                if ($this.CharacterList) {
                    $this.CharacterList
                } else { 
                    $this.CharacterList = ( $this.characters | % {
                        $x = [int]$_.split("/")[5]
                        (get-person $x $false).name
                        })
                    $this.CharacterList
            }
        }
    }
    return $film
}

function get-species($id, $addMethods = $true){
    $race = get_one species $id
    if ($addMethods) {
        add-member -InputObject $vehicle -MemberType noteproperty -name PeopleList -value $false
        add-member -InputObject $race -MemberType ScriptMethod -name PeopleNames -Value {
           if ($this.PeopleList) {
                $this.PeopleList
                } else { 
                    $this.PeopleList = ( $this.people | % {
                    $x = [int]$_.split("/")[5]
                    (get-person $x $false).name
                    })
                    $this.PeopleList
            }
        }
    }
    return $race
}

function get-race($id, $addMethods = $true){
    get-species $id $addMethods
}

function get-starship($id, $addMethods = $true){
    $starship = get_one starships $id
    if ($addMethods) {
        add-member -InputObject $vehicle -MemberType noteproperty -name PilotList -value $false
        add-member -InputObject $starship -MemberType ScriptMethod -name PilotNames -Value {
         if ($this.PilotList) {
                $this.PilotList
                } else { 
                    $this.PilotList = ( $this.pilots | % {
                    $x = [int]$_.split("/")[5]
                    (get-person $x $false).name
                    })
                    $this.PilotList
            }
        }
    }
    return $starship
}

function get-vehicle($id, $addMethods = $true){
    $vehicle = get_one vehicles $id
    if ($addMethods) {
        add-member -InputObject $vehicle -MemberType noteproperty -name PilotList -value $false
        add-member -InputObject $vehicle -MemberType ScriptMethod -name PilotNames -Value {
            if ($this.PilotList) {
                $this.PilotList
                } else { 
                    $this.PilotList = ( $this.pilots | % {
                    $x = [int]$_.split("/")[5]
                    (get-person $x $false).name
                    })
                    $this.PilotList
            }
        }
    }
    return $vehicle
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
