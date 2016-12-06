function get-all($resource) {
    $returns = @()
    $count = ((invoke-webrequest http://swapi.co/api/$resource).content | convertfrom-json).count
    $pagelimit = [math]::ceiling($count / 10)
    1..$pagelimit | % {$returns += ((invoke-webrequest http://swapi.co/api/$resource/?page=$_).content | convertfrom-json).results }
    return $returns
    }

function get_one($resource, $id) {
    return (invoke-webrequest http://swapi.co/api/$resource/$id/).content | convertfrom-json 
}

function get-person($id){
    try { get_one people $id }
    catch {"$id not found"}
}

function get-planet($id){
    try {get_one planets $id}
    catch {"$id not found"}
}

function get-film($id){
    try {get_one films $id}
    catch {"$id not found"}
}

function get-soecies($id){
    try {get_one species $id}
    catch {"$id not found"}
}

function get-starship($id){
    try {get_one starships $id}
    catch {"$id not found"}
}

function get-vehicle($id){
    try {get_one vehicles $id}
    catch {"$id not found"}
}

function pad-CRLFLine ($line,$padlength, $offset){
    $length = $Line.length
    if ($length -eq $padlength) {
        " $($Line.insert(($padlength - 1)," "))" 
    } else {
        " " + $line.insert(($length - $offset), (" " * ($offset + ($padlength - $length))))
    }
}

function play-crawl ($film){
    $crawl = $film.opening_crawl.split("`n")
    $max = ($crawl | % { $_.length } | measure-object -maximum ).maximum  
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