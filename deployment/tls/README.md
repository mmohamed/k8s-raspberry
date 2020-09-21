# Set up a free SSL for your domain with LetsEncrypt & CertBot


##### 1- Install Certboat :
```
sudo apt-get install certbot
```

##### 1- Make SSL :
* You can use manual mode to get SSL, run : 
```
sudo certbot certonly --manual --preferred-challenges dns
# > say Y
# > give your domain *.medinvention.dev (it's wildcard for all subdomains and not root domain)
# > Copy TXT record & Create TXT record named "_acme-challenge" with security token as value in your domain provider dashboard

# > Wait some minutes and Check TXT record 
dig -t txt *.medinvention.dev

# > Copy fullchain & private key to tls directory
sudo cp /etc/letsencrypt/live/medinvention.dev-0001/fullchain.pem crt-new.raw
sudo cp /etc/letsencrypt/live/medinvention.dev-0001/privkey.pem key-new.raw

# > Encode fullchain and private key to base64 to be used in secret
cat key-new.raw | base64 | tr -d '\n' > key-new.base64
cat crt-new.raw | base64 | tr -d '\n' > crt-new.base64

# > Update secret using new files
./renewSSL.sh

# > Check SSL 
echo | openssl s_client -connect wildcard.medinvention.dev:443 -servername wildcard.medinvention.dev

# > If it's OK backup and save
mv crt.raw crt-back.raw && mv key.raw key-back.raw
mv crt.base64 crt-back.base64 && mv key.base64 key-back.base64

mv crt-new.raw crt.raw && mv key-new.raw key.raw
mv crt-new.base64 crt.base64 && mv key-new.base64 key.base64
```
