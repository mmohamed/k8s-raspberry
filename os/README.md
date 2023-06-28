# Dynamic DNS

##### Up Dynamic DNS :
```
sed "s/{{USER}}/[DNSUSER]/" os/dyndns.sh.dist | sed "s/{{PASSWORD}}/[DNSPWD]/" | sed "s/{{HOST}}/[DNSHOST]/" > os/dyndns-[HOST].sh
chomod +x os/dyndns-[HOST].sh
./os/dyndns-[HOST].sh
```




