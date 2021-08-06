# Script version v1.0
# Author: Zohar Nissare-Houssen
# E-mail: z.nissare-houssen@snowflake.com
#
# README:
#     - Please check the following URLs for the driver to pick up:
#         ODBC:  https://sfc-repo.snowflakecomputing.com/odbc/linux/index.html
#         JDBC:  https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/
#         Spark: https://repo1.maven.org/maven2/net/snowflake/spark-snowflake_2.12
#         Note: For Spark, the docker currently uses Spark 3.1.1 with Scala 2.12.10

#!/bin/bash

export odbc_file=${odbc_file:-snowflake_linux_x8664_odbc-${odbc_version}.tgz}
export jdbc_file=${jdbc_file:-snowflake-jdbc-${jdbc_version}.jar}
export scala_version=${scala_version:-2.12}
export spark_file=${spark_file:-spark-snowflake_${scala_version}-${spark_version}.jar}
export bootstrap_version=`echo ${snowsql_version}|cut -c -3`
export snowsql_file=${snowsql_file:-snowsql-${snowsql_version}-linux_x86_64.bash}
cd /

echo "Downloading odbc driver version" ${odbc_version} "..."
curl -O https://sfc-repo.snowflakecomputing.com/odbc/linux/${odbc_version}/${odbc_file}

echo "Downloading jdbc driver version" ${jdbc_version} "..."
curl -O https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/${jdbc_version}/${jdbc_file}

echo "Downloading spark driver version" ${spark_version} "..."
curl -O https://repo1.maven.org/maven2/net/snowflake/spark-snowflake_${scala_version}/${spark_version}/${spark_file}

echo "Download SnowSQL client version" ${snowsql_version} "..."
curl -O https://sfc-repo.snowflakecomputing.com/snowsql/bootstrap/${bootstrap_version}/linux_x86_64/${snowsql_file}

tar -xzvf ${odbc_file}
./snowflake_odbc/iodbc_setup.sh

cp ${jdbc_file} /usr/local/spark/jars
cp ${spark_file} /usr/local/spark/jars

SNOWSQL_DEST=/usr/bin SNOWSQL_LOGIN_SHELL=/home/jovyan/.profile bash /${snowsql_file}
