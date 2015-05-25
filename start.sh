#!/bin/bash 
 cd riak-2.1.0/dev/ && sudo service apache2 restart && for node in dev*; do $node/bin/riak start; done 
 cd /home/dennis/newsteam/ebin/ && erl
