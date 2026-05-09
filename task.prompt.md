Generate a README.md containing instalation, usage, uninstallation, implementation details, etc.
Also generate a .claude.md for this project.

Project purpose: 
I want to minimize internet usage by caching web content (HTTP/HTTPS) using Squad.
The initial requirements:

``` 
use Squid docker image on FriendlyWRT (NanoPi R6S) for HTTP and HTTPS caching (with SSL bumping).
I prefer to have a script (or multiple scripts if needed) to automate as much as the process. 
I Have R6S with FriendlyWRT. My laptop has Windows 10. 
I want this scenario: Windows 10 (IP: 192.168.88.100) --> proxy to --> Squid container on R6S (R6S IP: 192.168.88.110) to cache HTTPS resources --> proxy to --> V2Ray proxy on my Windows 10 (Addr: 192.168.88.100:8080) --> connects to internet
If this scenario has any issue let me know.

Main resources to cache are JS,CSS , fonts and images and any other Web based resources which change rarely. HTML files, videos and compressed files should not be cached
```

Known issue:

The websites CA issuer in browser is R6S-SquidCA , It seems OK.
But all of requests are TCP_MISS:




```
root@FriendlyWrt:/srv/appdata/squid# docker exec squid-proxy tail -f /var/log/squid/access.log | grep "https://"

1776079863.247   3055 192.168.88.100 TCP_MISS/304 415 GET https://farsnews.ir/fonts/IRANSansX-Regular.woff - FIRSTUP_PARENT/192.168.88.100 -

1776079864.723   1031 192.168.88.100 TCP_MISS/304 415 GET https://farsnews.ir/service-worker.js - FIRSTUP_PARENT/192.168.88.100 -

```