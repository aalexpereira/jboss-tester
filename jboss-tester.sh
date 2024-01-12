#!/bin/bash

cat host.txt| parallel -j2 '
jboss01=$(curl -ks {}/jbossmq-httpil/HTTPServerILServlet|grep -oP "JBossMQ HTTP-IL"|head -n1)
jboss02=$(curl --head -ks {}/invoker/readonly|grep -oP "500 Internal Server Error"|head -n1)
jboss03=$(curl -ks --head {}/invoker/EJBInvokerServlet |grep -oP "x-java-serialized-object"|head -n1)
jboss04=$(curl -ks --head {}/invoker/JMXInvokerServlet |grep -oP "x-java-serialized-object"|head -n1)

if [ "$jboss01" = "JBossMQ HTTP-IL" ]
then
echo "{} Running JbossMQ - Possible vuln to CVE-2017-7504"
echo "{}" >> Jboss-hostservers
elif [ "$jboss02" = "500 Internal Server Error" ]
then
echo "{} Running Jboss HttpInvoker  - Possible vuln to CVE-2017-12149"
echo "{}" >> Jboss-hostservers
elif [ "$jboss03" = "x-java-serialized-object" ]
then
echo "{} Running Jboss EJBInvokerServlet - Possible vuln to JMXInvokerServlet-deserialization"
echo "{}" >> Jboss-hostservers
elif [ "$jboss04" = "x-java-serialized-object" ]
then
echo "{} Running Jboss JMXInvokerServlet - Possible vuln to JMXInvokerServlet-deserialization"
echo "{}" >> Jboss-hostservers
else
echo "{} Not vuln"
fi

'