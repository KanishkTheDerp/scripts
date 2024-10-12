#!/bin/bash

# Set read ahead to 256 KB
echo "Setting read-ahead to 256 KB..."
echo 256 | sudo tee /sys/block/sda/queue/read_ahead_kb

# Set I/O scheduler to mq-deadline
echo "Setting I/O scheduler to mq-deadline..."
echo mq-deadline | sudo tee /sys/block/sda/queue/scheduler

# Set journal mode to writeback for /dev/sda3
echo "Changing journaling mode to writeback for /dev/sda3..."
sudo tune2fs -o journal_data_writeback /dev/sda3

# Confirm settings
echo "Verifying changes..."

# Check read ahead
echo "Current read-ahead value:"
cat /sys/block/sda/queue/read_ahead_kb

# Check I/O scheduler
echo "Current I/O scheduler:"
cat /sys/block/sda/queue/scheduler

# Check journaling mode for /dev/sda3
echo "Current journaling mode for /dev/sda3:"
sudo tune2fs -l /dev/sda3 | grep 'Default mount options'

echo "Disk optimization script completed."
