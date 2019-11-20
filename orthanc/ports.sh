#!/bin/sh


for ip in 	\
	172.19.0.1	\
	10.244.0.1	\
	172.17.0.1	\
	172.31.43.216	\
	10.244.0.0	\
; do
 echo ""
 echo $ip
 telnet $ip 5432
done
