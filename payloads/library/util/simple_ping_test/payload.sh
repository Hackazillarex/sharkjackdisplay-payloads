#!/bin/bash
# Title: Simple Ping Test
# Author: Hak5Darren
# Props: Korben
# Description: Pings $IP and shows basic results
LED SETUP
IP="8.8.8.8"
CREATE_SPINNER "Starting DHCP"
  NETMODE DHCP_CLIENT
STOP_SPINNER
WAIT_FOR_LINK
WAIT_FOR_IP
SCREEN_WRITE "Pinging IP:"
SCREEN_WRITE "$IP"
ping $IP -c 2 && TEST="success" || TEST="fail"
if [ "$TEST" = "success" ]; then LED FINISH; SCREEN_WRITE "Success"; fi
if [ "$TEST" = "fail" ]; then LED FAIL; SCREEN_WRITE "Failed"; fi
