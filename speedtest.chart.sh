#!/bin/bash

# Netdata charts.d collector for fast.com internet speed test.
# Requires installed fast.com cli: `npm install --global fast-cli`.
speedtest_update_every=5
speedtest_priority=100

function speedtest_check {
	require_cmd fast || return 1
  return 0
}


speedtest_create() {
	# create a chart with 2 dimensions
	cat <<EOF
CHART system.connectionspeed '' "System Connection Speed" "Mbps" connectionspeed system.connectionspeed line $((speedtest_priority + 1)) $speedtest_update_every
DIMENSION down 'Down' absolute
DIMENSION up 'Up' absolute
EOF

	return 0
}

speedtest_update() {
	# do all the work to collect / calculate the values
	# for each dimension
	# remember: KEEP IT SIMPLE AND SHORT
  # Get the up and down speed. Parse them into separate values, and drop the Mbps.
	fast_output=$(fast -u)
	down=$(echo $fast_output | cut -d $'\n' -f 1 | cut -d ' ' -f 1)
	up=$(echo $fast_output | cut -d $'\n' -f 2 | cut -d ' ' -f 1)

	# write the result of the work.
	cat <<VALUESEOF
BEGIN system.connectionspeed
SET down = $down
SET up = $up
END
VALUESEOF

	return 0
}
