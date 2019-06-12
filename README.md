# Terraform Examples

## Developing Plan

It's useful to run this in a loop while working

```
get_instances () { aws ec2 describe-instances --no-verify-ssl 2>/dev/null | grep amazonaws.com | tr -d ' ' | sort -u | awk -F '"' '{print $(NF-1)}'; }
while true; do terraform destroy; sleep 1; terraform apply; sleep 5;    done
```
