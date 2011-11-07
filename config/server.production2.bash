#!/bin/bash

bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)
echo [[ -s "/usr/local/lib/rvm" ]] && source "/usr/local/lib/rvm" > ~/.bashrc

source ~/.bashrc

exit
