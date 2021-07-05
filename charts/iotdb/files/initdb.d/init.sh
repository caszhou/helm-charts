#!/bin/bash

set -ex

/iotdb/sbin/start-cli.sh -h ${host} -p ${port} -u ${user} -pw root -e "alter user root set password 'iotdb@IVC'"
/iotdb/sbin/start-cli.sh -h ${host} -p ${port} -u ${user} -pw ${password} -e "create function median as 'com.ivc.tool.iotdb.udf.UDTFMedian'"
/iotdb/sbin/start-cli.sh -h ${host} -p ${port} -u ${user} -pw ${password} -e "tracing on"

exit $?
