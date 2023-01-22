#/bin/bash

sam build && sam local invoke --log-file /tmp/sam.log
