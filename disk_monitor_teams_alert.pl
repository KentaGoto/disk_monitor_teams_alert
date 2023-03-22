use strict;
use warnings;
use JSON;
use LWP::UserAgent;
use Sys::Hostname;


# 監視対象のドライブと警告のしきい値を設定
my $drive_to_monitor = 'C:';
my $threshold_percentage = 95;
my $teams_webhook_url = 'https://365toin.webhook.office.com/'; # ここにWebhook URLを設定

# ホスト名
sub get_hostname {
    return hostname;
}

# Teamsにメッセージを投稿
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

# ディスク使用率をチェック
sub check_disk_space {
    my $output = `powershell -Command "Get-Volume -DriveLetter '$drive_to_monitor' | ForEach-Object { Write-Output ('Size:' + \$_.Size + ';FreeSpace:' + \$_.SizeRemaining) }"`;

    if ($output =~ /Size:\s*([0-9,.]+);FreeSpace:\s*([0-9,.]+)/) {
        my $total_bytes = int($1);
        my $free_bytes = int($2);

        # 使用率を計算
        my $used_bytes = $total_bytes - $free_bytes;
        my $usage_percentage = int($used_bytes / $total_bytes * 100);

        return ($usage_percentage, $total_bytes, $free_bytes);
    } else {
        die "Failed to get the disk space information for drive '$drive_to_monitor'.";
    }
}

# ディスク使用率を監視
while (1) {
    my ($usage_percentage, $total_bytes, $free_bytes) = check_disk_space();

    # 使用率がしきい値を超えているかどうかを判定
    if ($usage_percentage > $threshold_percentage) {
        my $message = get_hostname();
        $message .= "\n";
        $message .= "Warning: Disk usage for '$drive_to_monitor' is at $usage_percentage% (Threshold: $threshold_percentage%)";
        print "$message\n";
        send_to_teams($message);
    } else {
        print "Disk usage for '$drive_to_monitor' is at $usage_percentage% (Threshold: $threshold_percentage%)\n";
    }

    # 1分間スリープ
    sleep(60);
}
