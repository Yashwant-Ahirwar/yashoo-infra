# Hotfix: improve comments for operations
#!/bin/bash

# Domain to check
DOMAIN="yashoo.in"

# Get SSL expiry in days
SSL_DAYS_REMAINING=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null \
    | openssl x509 -noout -dates \
    | grep 'notAfter' \
    | sed 's/notAfter=//' \
    | xargs -I{} date -d "{}" +%s \
    | awk -v now=$(date +%s) '{print int(($1-now)/86400)}')

# Push SSL days remaining to CloudWatch
aws cloudwatch put-metric-data \
    --metric-name SSL_Days_Remaining \
    --namespace "Yashoo/Certbot" \
    --value "$SSL_DAYS_REMAINING" \
    --region eu-north-1

# Check certbot renew logs for failures (last run)
FAILURES=$(sudo grep -i "failed" /var/log/letsencrypt/letsencrypt.log | wc -l)

# Push Certbot failures to CloudWatch
aws cloudwatch put-metric-data \
    --metric-name Certbot_Renew_Failures \
    --namespace "Yashoo/Certbot" \
    --value "$FAILURES" \
    --region eu-north-1
