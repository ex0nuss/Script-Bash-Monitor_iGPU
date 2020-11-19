#!/bin/bash

### Path to script: /usr/local/sbin/monitor_igpu.sh
### Path to service for executing at startup: /etc/systemd/system/monitor_igpu.service



count=0

#Regex: Checks if it is a number
z_re='^[0-9]+$'

# prints iGPU-usage in rows   # reads output from intel_gpu_top command and saves it into $moment
sudo intel_gpu_top -o - | while read -r moment; do
  # counter for the foor-loop
  (( count++ ))

  # only every 15 secs (15 itterations) data is sent to pushgateway
  if [ "x$count" ==  "x15" ]; then

      # extracts current igpu usage - eg: '  5'
      igpuUsage=$(echo "$moment" | cut -c 9-11)
                                 # removes empty cells
      igpuUsage="$(echo $igpuUsage | tr -d ' ')"

      # checks if igpuUsage is a number
      if [[ $igpuUsage =~ $z_re ]]; then
        # pushes iGPU usage to pushgateway
        echo "igpuUsage $igpuUsage" | curl --data-binary @- http://127.0.0.1:9091/metrics/job/igpuUsage

        # resets counter
        count=0
     fi
  fi
done
