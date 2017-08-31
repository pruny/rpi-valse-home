#!/bin/bash

fail_func()
{
  #echo "starting service..."
  /bin/systemctl start LHT.service
}

/bin/systemctl is-active LHT.service >/dev/null 2>&1 || fail_func
