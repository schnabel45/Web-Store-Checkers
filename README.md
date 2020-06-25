# Web Stock Checkers
Scripts checking the stock availability of web storefronts.

## Get-LenovoLaptopStockStatus.ps1
This script is used to snipe good deals on laptops from Lenovo's website by checking the stock status of a specified 
model. The script will trigger a [BurntToast](https://github.com/Windos/BurntToast) notification with a persistent 
sound in Windows 10 once the model shows as in stock. Otherwise the script will output the available models from the 
store along with the stock status.

### Run Example
```powershell
$URI = "https://www.lenovo.com/us/en/laptops/thinkpad/thinkpad-x1/X1-Carbon-Gen-7/p/22TP2TXX17G"
Get-LenovoLaptopStockStatus.ps1 -URI $URI -Models @("20R1S04100", "20R10015US") -MonitorFrequency "00:05:00"
```
This example checks the status of the X1 Carbon Gen 7 model numbers 20R1S04100 and 20R10015US. The script will execute continuously 
every 5 minutes until stopped, even after finding that the device is in stock. The notifications will expire 
automatically before the next run.