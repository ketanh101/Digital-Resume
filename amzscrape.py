
# import libraries 

from bs4 import BeautifulSoup
import requests
import time
import datetime

import smtplib




# Connect to Website and pull in data

URL = 'https://www.amazon.com/2021-Apple-10-2-inch-Wi-Fi-256GB/dp/B09G96TFF7?ref_=Oct_DLandingS_D_2e7c895c_60'

headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36", "Accept-Encoding":"gzip, deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "DNT":"1","Connection":"close", "Upgrade-Insecure-Requests":"1"}

page = requests.get(URL, headers=headers)

soup1 = BeautifulSoup(page.content, "html.parser")

soup2 = BeautifulSoup(soup1.prettify(), "html.parser")

title = soup2.find(id='productTitle').get_text()

price = soup2.find('span',{'class':'a-offscreen'}).text.strip()


print(title)
print(price)



price2 = price.strip()[1:]
title = title.strip()

print(title)
print(price2)

type(price2)



import datetime

today = datetime.date.today()
print(today)




import csv

header = ['Title', 'Price', 'Date']
data = [title, price, today]

with open('AmazonWebScraperDataset.csv', 'w', newline ='',encoding='UTF8')as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerow(data)
    
    



import pandas as pd

df= pd.read_csv(r'C:\Users\khonr\AmazonWebScraperDataset.csv')

print(df)




#Appending data to csv

with open('AmazonWebScraperDataset.csv', 'a+', newline ='',encoding='UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(data)
    



def check_price():
    URL = 'https://www.amazon.com/2021-Apple-10-2-inch-Wi-Fi-256GB/dp/B09G96TFF7?ref_=Oct_DLandingS_D_2e7c895c_60'

    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36", "Accept-Encoding":"gzip, deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "DNT":"1","Connection":"close", "Upgrade-Insecure-Requests":"1"}

    page = requests.get(URL, headers=headers)

    soup1 = BeautifulSoup(page.content, "html.parser")
    
    soup2 = BeautifulSoup(soup1.prettify(), "html.parser")

    title = soup2.find(id='productTitle').get_text()

    price = soup2.find('span',{'class':'a-offscreen'}).text.strip()
    
    price2 = price.strip()[1:]
    title = title.strip()

    import datetime

    today = datetime.date.today()
    print(today)

    import csv

    header = ['Title', 'Price', 'Date']
    data = [title, price, today]

    with open('AmazonWebScraperDataset.csv', 'a+', newline ='',encoding='UTF8') as f:
        writer = csv.writer(f)
        writer.writerow(data)

        if(price < 389.00):
            send_mail()



while(True):
    check_price()
    time.sleep(86400)





import pandas as pd

df= pd.read_csv(r'C:\Users\khonr\AmazonWebScraperDataset.csv')

print(df)




def send_mail():
    server = smtplib.SMTP_SSL('smtp.gmail.com',465)
    server.ehlo()
    #server.starttls()
    server.ehlo()
    server.login('honrao.ketan@gmail.com','xxxxxxxxxxxxxx')
    
    subject = "The Item you want is on sale! Now is your chance to buy!"
    body = "Link here: https://www.amazon.com/2021-Apple-10-2-inch-Wi-Fi-256GB/dp/B09G96TFF7?ref_=Oct_DLandingS_D_2e7c895c_60"
   
    msg = f"Subject: {subject}\n\n{body}"
    
    server.sendmail(
        'AlexTheAnalyst95@gmail.com',
        msg
     
    )






