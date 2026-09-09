#!/usr/bin/env bash
START_TIME=$(date +%s)
CPU_USAGE=0
if [ -f /sys/fs/cgroup/cpu.stat ]; then
  CPU_USAGE=$(grep "usage_usec" /sys/fs/cgroup/cpu.stat | awk '{print $2}')
fi
echo "START_TIME=${START_TIME}" > /tmp/job-metrics.env
echo "START_CPU_USAGE=${CPU_USAGE}" >> /tmp/job-metrics.env
exit 0
