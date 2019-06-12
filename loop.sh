#!/bin/bash

while true
do
  terraform destroy
  terraform apply
  sleep 5
done
