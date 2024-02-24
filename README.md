### Overview
This Web_Exploration's goal is a Python script meant to grab a list of 250,000 URLs from a local Excel sheet, gather the redirect and scrape relevant information from the pages 
for each one, package it into an object and send the result object back to the Excel sheet.

### Procedure
#### Locations/Where to Start
URL_Processor houses all the relevant scripts \
First part of script (redirects) handled in Redirect_Script_Send.ipynb therein. That work is now integrated into the scraping portion in Website_Information_Scraper.ipynb located there as well. \
Reports_Notes_Explorations.ipynb there is self-explanatory. \
The Trials folder contains mostly failed attempts/explorations. \
The Excel_Sheets_Public folder contains a csv file that has the start of one list of URLs to see the effect of script. \
The csv files will contain 9 columns: \
Company ID (18 Char) | Company Record Type | Company Name | Website | Website Redirect | Nav | Headers | Home Page | First Page (10 upon integration of 'Metadata' column before 'Nav')\

The place to start is integrated_main2() in Website_Information_Scraper.ipynb, it all stems from there. Incorporates the API for metadata, the asynchronous redirect capturing and the now asynchronous scraping.

To use the script, change the file_path from ./Excel_Sheets/Website_Redirects_230919.csv to ./Excel_Sheets_Public/Website_Redirects_230919.csv

And you need your own free API key from jsonlink.com for the metadata grabbing (not yet fully integrated) and a download of a local model (say from LM Studio) if you want to embark on the 'Mistral Exploration'. You do not need an api key from OpenAI for that.

#### Process
The process for scraping is as follows:
An HTTPRequest is sent via the Python requests library and upon success, the 'nav' setup for the website is scraped with the BeautifulSoup(bs4) library. \
The script then proceeds to scrape the home page (original URL) and the first relevant href found in the nav.

A 'relevant href' is defined as an href with the same netloc as the original URL, but is not the same URL entirely. In most cases, this returns the first page on the website 
besides the home page, which contains substantial information about the company and products it sells. \
If at any point in this process, an error is thrown, then the script defaults to Selenium scraping. This is the backup because Selenium starts its own driver - this allows it 
to bypass robot detection much more frequently, but it is also a much longer process. Selenium analogously scrapes for the nav, finds the first relevant href and scrapes both 
the home page and the first page. My next goal, to tackle the constraint of time, is to spread the asynchroneity from the beginning of the scraping lower down into it whereby 
the nav, the home page and the first page will each have their designated drivers. \
As of now, two drivers start for each URL visited by the Selenium route (one for the nav and a stealth driver to reliably scrape the two website pages). If I have three drivers 
in total, this reduces the overhead cost of repeatedly starting drivers and the third, 'first page', driver, can await the nav driver to finish the nav scraping/parsing so that 
it gets the first relevant href.