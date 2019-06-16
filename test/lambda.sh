#!/bin/bash

aws lambda  invoke --function-name put_helloworld \
 --payload fileb://lambda_put.json output_put.txt

aws lambda  invoke --function-name get_helloworld \
--payload fileb://lambda_get.json output_get.txt
