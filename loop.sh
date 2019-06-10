#!/bin/bash

while true
do
  terraform destroy
  terraform apply
done
