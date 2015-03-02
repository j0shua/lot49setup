#!/bin/bash
    log_format  main  '$time_iso8601\t$remote_addr\t$http_x_forwarded_for\t$request\tM1\t$status\t$request_time\t$body_bytes_sent\t$http_referer\tM2\t$http_user_agent';