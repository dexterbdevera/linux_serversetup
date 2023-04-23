# Linux shell script prepare the server before joining to Domain

This shell script is tested  with Linux flavors like Centos 7 or Almalinux 8 that are binary-compatible with Red Hat Enterprise Linux (RHEL).

The following will be executed in sequence:

1. Update Server Hostname
2. Update Server's Application Header to Warning Banner
3. Update Server Network-script
4. Restart Network service and NetworkManager 
5. To enable timestamp on history
6. Create Interim Local Admin Account to Apps Vendor

Goodluck!