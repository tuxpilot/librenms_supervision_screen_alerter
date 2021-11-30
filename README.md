# librenms_supervision_screen_alerter
LibreNMS alert module for supervision screen 

Used to check if any alert has recently been sent as a log to what is hosting the script.
If the alert is new and contains a critical alert : then an audio sound is provided and a GPIO action is made so that if you have a blinking led device for example, it turns it on and off quickly after to notify a critical alert just poped in.

Can be implemented for example on an Raspberry PI, connected to a monitoring screen.

Installation steps: 

sudo apt update

sudo apt install rsyslog

git clone https://github.com/tuxpilot/librenms_supervision_screen_alerter.git

sudo mkdir /opt/librenms_addon_scripts/

mv librenms_supervision_screen_alerter /opt/librenms_addon_scripts/

cd /opt/librenms_addon_scripts/librenms_supervision_screen_alerter

cp new_alert_checker.service /etc/systemd/system/

sudo systemctl enable new_alert_checker.service

echo '0  1    * * *   root    cd /opt/librenms_addon_scripts/librenms_supervision_screen_alerter && ./temp_ignore_auto_delete.sh' >> /etc/crontab

sudo chown pi:pi /opt/librenms_addon_scripts/* -R

sudo chmod +x new_alert_checker.sh

sudo chmod +x temp_ignore_auto_delete.sh

Go to your librenms instance and log in the WebUI with an admin account.

Go to the 'alert' tab and click on 'alert transport'

Create a new alert transport and fill up the new alert transport with the following informations : 

___________________________
  Transport name: \<your transport name\> 
  
  Transport type: Syslog 
  
  Default Alert: YES 
  
  Host: \<The ip of the device hosting the script\>
  
  Port: 514 
  
  Facility: criticity 
___________________________


Unless you want to get busy spliting the log files or this is a non dedicated device to this usage, you can edit the rsyslog configuration file to replace the values for the log file destination of all the events with this:  

/etc/rsyslog.conf (find the values on the left and replace them with the values as shown below)
___________________________
  auth,authpriv.*                 "/var/log/rsyslog/%HOSTNAME%/log.log"
  
  *.*;auth,authpriv.none          -"/var/log/rsyslog/%HOSTNAME%/log.log"
  
  #cron.*                         /var/log/cron.log
  
  daemon.*                        -"/var/log/rsyslog/%HOSTNAME%/log.log"
  
  kern.*                          -"/var/log/rsyslog/%HOSTNAME%/log.log"
  
  lpr.*                           -"/var/log/rsyslog/%HOSTNAME%/log.log"
  
  mail.*                          -"/var/log/rsyslog/%HOSTNAME%/log.log"
  
  user.*                          -"/var/log/rsyslog/%HOSTNAME%/log.log"
  
___________________________
  
Retrieve the hostname of your LibreNMS server and replace it in the shell script file:

/opt/librenms_addon_scripts/librenms_supervision_screen_alerter/new_alert_checker.sh
___________________________
  rsyslog_file='/var/log/rsyslog/\<YOUR_LIBRENMS_SERVER_HOSTNAME\>/log.log'
___________________________

Start up the service : 

sudo systemctl start new_alert_checker.service
  
  
  
  
You can follow the service behavior with the service command, and the debug file:
sudo systemctl status new_alert_checker.service
tail -f /opt/librenms_addon_scripts/librenms_supervision_screen_alerter/debug.txt
