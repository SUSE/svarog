# svarog

This gem provides a simple way to send the notification messages via IRC or Mail

## Getting Started  
```bash
git clone https://github.com/vlewin/svarog.git

sudo bundle install  

thin start -p <PORT> -d 
``` 


Svarog accepts POST requests on `http://localhost:<PORT>`  
Required parameters:
```ruby
{ 
  "sender" => "stealth-new", 
  "text" => "Notification message", 
  "type" => "warning"
}
```  
