#!/bin/bash

host=iotdb-0.iotdb-headless.middleware.svc.cluster.local
rpcPort=6667
user=root
pass=iotdb@IVC

/iotdb/sbin/start-cli.sh -h ${host} -p ${rpcPort} -u ${user} -pw ${pass} -e "create function median as 'com.ivc.tool.iotdb.udf.UDTFMedian'"

exit $?
