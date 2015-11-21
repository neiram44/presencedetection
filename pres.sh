#!/bin/sh
###############################################################
# Proximity detection
#
# A script designed to run on a router running DD-WRT to detect certain devices connected to the router.
# It runs at startup and runs continually, checking for a specific list of devices (phones/laptop, etc)
# that connect wirelessly to the router.  Once a device is connected, the OpenHAB status will
# be updated with either an ON or OFF.  Make sure you set up a switch item in OpenHAB for each device
# you want to track.
#
# The searching frequency can be adjusted to be slower/faster depending on your requirements. Searching too fast
# could burden your router.  Too slow might not update the status as necessary for the application.
#
  
   
# Make changes below
# MAC address of each device to watch. Don't leave blank. 
# For security purposes, if your router requires a password, even if someone could clone the MAC of your 
# phone, they would still require the password of your network to link to your router. 
macdevice1="00:00:00:00:00:00"    #Aaron Phone
macdevice2="00:00:00:00:00:00"    #Device 2

  
  
  
# Occupied and unoccupied delay in seconds to check status
# Adjust for shorter/longer wait times.  For instance, when one device is already 
# connected, you might want to check less frequently.  This could also delay the 
# notification of a disconnect.
delay_occupied=4
delay_unoccupied=2
  
# initial testing loop count - uncomment the counter near the bottom of the script for testing only. 
limit=120
  
###############################################
# do not change below here
###############################################
  
sleep
#initialize internal variables
  
# status of each MAC. 0=disconnected. 1=connected.  -1 initially forces isy update first loop
macconnected1=-1
macconnected2=-1
connected=-1
# total number of currently conencted devices.   
connected=0
counter=1
  
# Initial testing loop.  Will run continually after testing is complete
while [ $counter -lt $limit ]; do
  
#maclist stored mac listing in router from status screen
maclist=$(wl -i $(nvram get wl0_ifname) assoclist | cut -d" " -f2)
  
#reset current status. Two variables are used for each device.  The past known status and the current 
# status.  Only a change is reported to the ISY.  Otherwise, it would constantly be updating the ISY with 
# the current status creating unnecessary traffic for both the router and the ISY
maccurrent1=0;
maccurrent2=0;

  
# compare each device that is currently connected to the MAC devices we want to watch.
for mac in $maclist; do
case $mac in
   "$macdevice1") maccurrent1=1;;
   "$macdevice2") maccurrent2=1;;

esac
done
  
# Look for a change in status from the old known to the current status.
# If it changed, update the ISY. Otherwise it leaves it as is. 
let current=$maccurrent1+$maccurrent2

if [ $current -ne $connected ]; then
  if [ $current -gt 0 ]; then
  #Stop SS
  else
  # Start SS
  fi
  
else
#Same Status than before
fi


  

  
connected=$current

  
# Delay (sleep) depending on the connection status. 
# No devices connected could delay less.  Once a device is connected, it could delay longer. 
if [ $connected -gt 0 ]; then
    sleep $delay_occupied
    else
    sleep $delay_unoccupied
fi
  
#for testing only - uncomment to have the looping stop at X loops defined in variable:  limit. 
#let counter=$counter+1 
done
