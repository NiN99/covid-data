$dir = "$HOME/Documents/covid/temp"
$Null = New-Item -Path $dir -ItemType Directory -ErrorAction SilentlyContinue

# Could switch to https://github.com/nytimes/covid-19-data/issues/180
$population = Import-Csv $dir/Wiki-Population.csv # CSV [State,Population] Manually created from https://simple.wikipedia.org/wiki/List_of_U.S._states_by_population

#region states
Invoke-WebRequest -Uri https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv -OutFile $dir/us-states.csv
$USStates = Import-Csv $dir/us-states.csv

$SortedStates = $USStates | Sort-Object state,date

$sub = $SortedStates
$count = $sub.Count
$out = ForEach ($Index in (1..($count - 1))) {  #Need to do this to get previous entry for calculations
    Write-Host "States $Index of"($count -1)
    $Lastline = $sub[$Index -1]
    $ThisLine = $sub[$Index]
    $TotalCases = $ThisLine.cases
    $TotalDeaths = $ThisLine.deaths

    $popdata = ($population | Where-Object {$_.State -eq $ThisLine.state})
        [int]$StatePop = $popdata | Select-Object -ExpandProperty Population
    if ($TotalCases -ne 0) {$TotalPctOfPop = $TotalCases / $StatePop} else {$TotalPctOfPop = 0}

    if ($Lastline.state -eq $ThisLine.state) {
        $NewDeaths = ($ThisLine.deaths - $Lastline.deaths)
        $NewCases = ($ThisLine.cases - $Lastline.cases)
    }
    else {
        $NewDeaths = $ThisLine.deaths
        $NewCases = $ThisLine.cases
    }

    $InfectRate = $NewCases/$StatePop
    if ($TotalDeaths) {$FatalityRate = ($TotalDeaths / $TotalCases)} else {$FatalityRate = 0}
    [pscustomobject]@{
        State = $sub[$Index].state
        Date = $sub[$Index].date
        Population = $StatePop            
        "New Cases" = $NewCases
        "New Deaths" = $NewDeaths
        "Total Cases" = $TotalCases
        "Total Deaths" = $TotalDeaths
        "New Infect Rate/Population" = $InfectRate
        "Fatality Rate" = $FatalityRate
        "Percent of Population Infected" = $TotalPctOfPop
        }
}

$OutFileStates = "$dir/new-us-states.csv"
$out | Export-Csv -Path $OutFileStates
#endregion states

#region Counties

Invoke-WebRequest -Uri https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv -OutFile $dir/us-counties.csv
$UScounties = Import-Csv $dir/us-counties.csv
$SortedCounties = $UScounties | Sort-Object state,county,date

$sub = $SortedCounties
$count = $sub.Count
$out = ForEach ($Index in (1..($count - 1))) {  #Need to do this to get previous entry for calculations
    Write-Host "Counties $Index of"($count -1)
    $Lastline = $sub[$Index -1]
    $ThisLine = $sub[$Index]
    $TotalCases = $ThisLine.cases
    $TotalDeaths = $ThisLine.deaths

    $popdata = ($population | Where-Object {$_.State -eq $ThisLine.state})
        [int]$StatePop = $popdata | Select-Object -ExpandProperty Population
    if ($TotalCases -ne 0) {$TotalPctOfPop = $TotalCases / $StatePop} else {$TotalPctOfPop = 0}

    if ($Lastline.state -eq $ThisLine.state) {
        if ($Lastline.county -eq $ThisLine.county) {
            $NewDeaths = ($ThisLine.deaths - $Lastline.deaths)
            $NewCases = ($ThisLine.cases - $Lastline.cases)
        }
        else {
            $NewDeaths = $ThisLine.deaths
            $NewCases = $ThisLine.cases
        }
    }
    else {
        $NewDeaths = $ThisLine.deaths
        $NewCases = $ThisLine.cases
    }

    $InfectRate = $NewCases/$StatePop
    if ($TotalDeaths) {$FatalityRate = ($TotalDeaths / $TotalCases)} else {$FatalityRate = 0}
    [pscustomobject]@{
        State = $ThisLine.state
        County = $ThisLine.county
        Date = $ThisLine.date
        Population = $StatePop            
        "New Cases" = $NewCases
        "New Deaths" = $NewDeaths
        "Total Cases" = $TotalCases
        "Total Deaths" = $TotalDeaths
        "New Infect Rate/Population" = $InfectRate
        "Fatality Rate" = $FatalityRate
        "Percent of Population Infected" = $TotalPctOfPop
        }
}

$OutFileCounties = "$dir/new-us-counties.csv"
$out | Export-Csv -Path $OutFileCounties
#endregion Counties

Write-Host "Created $OutFileStates"
Write-Host "Created $OutFileCounties"
