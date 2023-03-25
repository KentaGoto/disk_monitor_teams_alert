# disk_monitor_teams_alert

This Perl script monitors the disk usage of a specified drive on a Windows machine and sends an alert to a Microsoft Teams channel using a webhook when the disk usage exceeds a predefined threshold.

## Dependencies

The script requires the following Perl modules:

- JSON
- LWP::UserAgent
- Sys::Hostname
- Configuration

Before running the script, make sure to configure the following variables:

$drive_to_monitor: The drive letter of the disk to monitor, e.g., 'C:'.
$threshold_percentage: The percentage of disk usage that will trigger an alert when exceeded, e.g., 95.
$teams_webhook_url: The URL of the Microsoft Teams webhook that will receive the alerts.
Usage

Run the script on a Windows machine using a Perl interpreter. The script will run continuously, checking disk usage every minute and sending alerts to the configured Microsoft Teams channel when the disk usage exceeds the defined threshold.

## Code Overview

Import necessary modules.
Set up configuration variables.
Define helper functions for getting the hostname, sending messages to Teams, and checking disk space.
Run the main monitoring loop:
Check disk usage.
If the usage exceeds the threshold, send an alert to the Microsoft Teams channel.
Sleep for 1 minute before checking again.

## Note

This script is intended to run on a Windows machine with a Perl interpreter installed. The disk usage check relies on PowerShell commands specific to Windows.

## Requires
- Perl 5  
- Windows  
- Teams  

## License
MIT

## Author
Kenta Goto
