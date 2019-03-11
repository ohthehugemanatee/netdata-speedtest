#!/bin/bash

# Netdata charts.d collector for fast.com internet speed test.
# Requires installed speedtest.com cli: `pip install speedtest-cli`
speedtest_update_every=60
speedtest_priority=100

speedtest_check() {
  require_cmd speedtest-cli || return 1
  return 0
}


speedtest_create() {
	# create a chart with 2 dimensions
	cat <<EOF
CHART system.connectionspeed '' "System Connection Speed" "Mbps" "Connection Speed" system.connectionspeed line $((speedtest_priority + 1)) $speedtest_update_every
DIMENSION down 'Down' absolute 1 1000000
DIMENSION up 'Up' absolute 1 1000000
EOF

	return 0
}

speedtest_update() {
	# do all the work to collect / calculate the values
	# for each dimension
	# remember: KEEP IT SIMPLE AND SHORT
  # Get the up and down speed. Parse them into separate values, and drop the Mbps.
  speedtest_output=$(speedtest-cli --single --csv)
  down=$(echo $speedtest_output | cut -d ',' -f 7 | cut -d '.' -f 1)
  up=$(echo $speedtest_output | cut -d ',' -f 8 | cut -d '.' -f 1)

	# write the result of the work.
	cat <<VALUESEOF
BEGIN system.connectionspeed
SET down = $down
SET up = $up
END
VALUESEOF

	return 0
}
