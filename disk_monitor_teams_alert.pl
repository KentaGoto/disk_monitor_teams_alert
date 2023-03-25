use strict;
use warnings;
use JSON;
use LWP::UserAgent;
use Sys::Hostname;


# Set monitored drives and warning thresholds.
my $drive_to_monitor = 'C:';
my $threshold_percentage = 10;
my $teams_webhook_url = 'https://365toin.webhook.office.com/'; # Webhook URL

# Hostname
sub get_hostname {
    return hostname;
}

# Send to Teams message.
sub send_to_teams {
    my $message = shift;
    my $ua = LWP::UserAgent->new;
    my $req = HTTP::Request->new('POST', $teams_webhook_url);
    $req->header('Content-Type' => 'application/json');
    my $payload = {
        '@type' => 'MessageCard',
        '@context' => 'http://schema.org/extensions',
        'text' => $message
    };
    $req->content(encode_json($payload));
    $ua->request($req);
}

# Check disk usage.
sub check_disk_space {
    my $output = `powershell -Command "Get-Volume -DriveLetter '$drive_to_monitor' | ForEach-Object { Write-Output ('Size:' + \$_.Size + ';FreeSpace:' + \$_.SizeRemaining) }"`;

    if ($output =~ /Size:\s*([0-9,.]+);FreeSpace:\s*([0-9,.]+)/) {
        my $total_bytes = int($1);
        my $free_bytes = int($2);

        # Calculate utilization.
        my $used_bytes = $total_bytes - $free_bytes;
        my $usage_percentage = int($used_bytes / $total_bytes * 100);

        return ($usage_percentage, $total_bytes, $free_bytes);
    } else {
        die "Failed to get the disk space information for drive '$drive_to_monitor'.";
    }
}

# Monitor disk utilization.
while (1) {
    my ($usage_percentage, $total_bytes, $free_bytes) = check_disk_space();

    # Determine if utilization exceeds thresholds.
    if ($usage_percentage > $threshold_percentage) {
        my $hostname = get_hostname();
        my $message .= "Warning: Disk usage for '$drive_to_monitor' is at $usage_percentage% (Threshold: $threshold_percentage%)";
		my $body = <<EOF;
$hostname
$message
EOF

        print $body . "\n";
        send_to_teams($message);
    } else {
        print "Disk usage for '$drive_to_monitor' is at $usage_percentage% (Threshold: $threshold_percentage%)\n";
    }

    # Sleep for 1 minute.
    sleep(60);
}
