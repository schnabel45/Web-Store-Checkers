param(
    # URI to Product Page
    [Parameter(Mandatory=$true)]
    [string]
    $URI,
    # Model Number
    [Parameter(Mandatory=$true)]
    [string]
    $Model,
    # MonitorFrequency
    [timespan]
    $MonitorFrequency = $(New-TimeSpan)
)

#Requires -Module BurntToast

<#
.SYNOPSIS
    Reports the stock status for a model of Lenovo laptops such as the X1 Carbon
.DESCRIPTION
    Used to snipe good deals from Lenovo's website.
.EXAMPLE
    PS C:\> Get-LenovoLaptopStockStatus.ps1 -URI $URI -Model "20R10015US"
    Check the specified URI to see if model 20R10015US is in stock
.INPUTS
    URI: URI of the model's webpage, for example:
        https://www.lenovo.com/us/en/laptops/thinkpad/thinkpad-x1/X1-Carbon-Gen-7/p/22TP2TXX17G
    Model: Model Identifier you want to track. For example 20R10015US
    MonitorFrequency: Timespan for how long between recurring checks.
.OUTPUTS
    Windows 10 Notification with Alarm Sound every $MonitorFrequency when the model is in stock.
    Otherwise a table of the current models listed on teh $URI along with their price and stock status
#>

function Get-CurrentStock {
    param (
        $uri
    )
    $webPage = Invoke-WebRequest -Uri $URI
    
    $stockOptions = $webPage.ParsedHtml.body.getElementsByClassName("tabbedBrowse-productListing")
    $parsedStock = @()
    foreach($stockItem in $stockOptions){
        $partNumber = $stockItem.getElementsByClassName("partNumber")
        $price = $stockItem.getElementsByClassName("pricingSummary-details-final-price")
        $stockMessage = $stockItem.getElementsByClassName("stock_message")
        $buttonText = $stockItem.getElementsByClassName("tabbedBrowse-productListing-button-container")[0].getElementsByClassName("product_detail_pages_models_form_submit")[0].innertext

        $parsedItem = '' | Select-Object PartNumber, Price, InStock

        if(($null -ne $buttonText) -and ($buttonText.Equals("Customize"))){
            $parsedItem.PartNumber = "Custom Build"
        } else {
            $parsedItem.PartNumber = $partNumber[0].innerText.Split(":")[1].Trim()
        }

        $parsedItem.Price = $price[0].innerText
        $parsedItem.InStock = $true

        if($null -ne $stockMessage[0].innerText){
            $parsedItem.InStock = $false
        }

        $parsedStock += $parsedItem
    }

    return $parsedStock
}

do {
    Write-Output $(Get-Date)
    $webStock = Get-CurrentStock -uri $uri

    if($webStock.PartNumber -icontains $Model){
        $preferredModel = $webStock | Where-Object{$_.PartNumber -ieq $Model}
        if($preferredModel.InStock){
            $notificationExpiration = New-TimeSpan -Minutes 5
            if($MonitorFrequency -gt 0){
                $notificationExpiration = $MonitorFrequency
            }
            New-BurntToastNotification -Text "$Model is now in stock on Lenovo's website." `
                -Sound 'Alarm' `
                -ExpirationTime $(Get-Date).Add($notificationExpiration)
        } else {
            $webStock | Format-Table
        }
    } else {
        Write-Output "Lenovo no longer has model $Model"
    }
    Start-Sleep -Seconds $MonitorFrequency.TotalSeconds
} while($MonitorFrequency -ne 0)