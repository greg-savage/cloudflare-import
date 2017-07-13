## Synopsis

Import set of zone files from BIND server.

## Code Example

```
ruby import.rb
```

## Installation

1. Download the Code
2. Create directory for your Zone files
3. Export your credentials for CloudFlare

   ```
   export CLOUDFLARE_EMAIL='<email>'
   export CLOUDFLARE_KEY='<key>' 
   ```
4. Edit Script to point to directory with zones

   ```$xslt
   #### Configure ####
   zone_dir = "<directory with zone>"
   #### Configure ####
   ```
5. Logs are output to import.log in the current directory

## Contributors

Greg Savage gsavage@spireon.com