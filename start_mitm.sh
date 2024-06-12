#!/bin/bash



echo "test"
mitmdump --mode transparent --showhost -s /root/.mitmproxy/block.py &
echo "test2"