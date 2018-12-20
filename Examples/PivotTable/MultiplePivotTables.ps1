$data = ConvertFrom-Csv @"
Region,Date,Fruit,Sold
North,1/1/2017,Pears,50
South,1/1/2017,Pears,150
East,4/1/2017,Grapes,100
West,7/1/2017,Bananas,150
South,10/1/2017,Apples,200
North,1/1/2018,Pears,100
East,4/1/2018,Grapes,200
West,7/1/2018,Bananas,300
South,10/1/2018,Apples,400
"@ | Select-Object -Property Region, @{n="Date";e={[datetime]::ParseExact($_.Date,"M/d/yyyy",(Get-Culture))}}, Fruit, Sold

$xlfile="$env:temp\multiplePivotTables.xlsx"
rm $xlfile -ErrorAction SilentlyContinue

$excel = $data | Export-Excel $xlfile -PassThru -AutoSize -TableName FruitData

$pivotTableParams = @{
    PivotTableName = "ByRegion" 
    Address = $excel.Sheet1.cells["F1"] 
    SourceWorkSheet = $excel.Sheet1
    PivotRows = echo Region Fruit Date
    PivotData = @{'sold'='sum'} 
    PivotTableStyle = 'Light21'
    GroupDateRow = "Date"
    GroupDatePart = echo Years Quarters
}

$pt = Add-PivotTable @pivotTableParams -PassThru
#$pt.RowHeaderCaption ="By Region,Fruit,Date"
$pt.RowHeaderCaption = "By " + ($pivotTableParams.PivotRows -join ",")

$pivotTableParams.PivotTableName="ByFruit"
$pivotTableParams.Address = $excel.Sheet1.cells["J1"] 
$pivotTableParams.PivotRows = echo Fruit Region Date

$pt = Add-PivotTable @pivotTableParams -PassThru
$pt.RowHeaderCaption ="By Fruit,Region"

$pivotTableParams.PivotTableName="ByDate"
$pivotTableParams.Address = $excel.Sheet1.cells["N1"] 
$pivotTableParams.PivotRows = echo Date Region Fruit 

$pt = Add-PivotTable @pivotTableParams -PassThru
$pt.RowHeaderCaption ="By Date,Region,Fruit"

$pivotTableParams.PivotTableName="ByX"
$pivotTableParams.Address = $excel.Sheet1.cells["S1"] 
$pivotTableParams.GroupDatePart = echo Years 

$pt = Add-PivotTable @pivotTableParams -PassThru
$pt.RowHeaderCaption ="By Years,Region"


Set-ExcelColumn -Worksheet $excel.Sheet1 -Column 2 -AutoSize

Close-ExcelPackage $excel -Show
