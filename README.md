# Introduction

Snowtire is a docker image which aims to provide Snowflake users with a turn key docker environment already set-up with Snowflake drivers of the version of your choice with a comprehensive data science environment including Jupyter Notebooks, Python, Spark, R to experiment the various Snowflake connectors available: 

- ODBC
- JDBC
- Python Connector
- Spark Connector
- SnowSQL Client.

SQL Alchemy python package is also installed as part of this docker image.

The base docker image is [Jupyter Docker Stacks](https://github.com/jupyter/docker-stacks). More specifically, the image used is [jupyter/all-spark-notebook](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-all-spark-notebook) which provides a comprehensive jupyter environment including r, sci-py, pyspark and scala.

Please review the [licensing terms](https://raw.githubusercontent.com/jupyter/docker-stacks/master/LICENSE.md) of the above mentioned project.

**NOTE: Snowtire is not officially supported by Snowflake, and is provided as-is.**

# Prerequisites

- You need git on your Mac or Windows
- You need to download and install [Docker Desktop for Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac) or [Docker Desktop for Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows). You may need to create an account on Docker to be able to download it.

**NOTE FOR WINDOWS**

On Windows, a common issue encountered is the configuration of line endings, which adds default CRLF Windows line endings to the script deploy_snowflake.sh causing the script to fail. You can either configure [```core.autocrlf```](https://docs.github.com/en/free-pro-team@latest/github/using-git/configuring-git-to-handle-line-endings#refreshing-a-repository-after-changing-line-endings) to ```false```, or use an editor like Notepad+++ to open the deploy_snowflake.sh file and save it in UNIX mode which will convert CRLF line endings into LF before you build the snowtire docker image.


# Instructions

## Download the repository

Change the Directory to a location where you are storing your Docker images:

```
mkdir DockerImages
cd DockerImages
git clone https://github.com/zoharsan/stv2_beta.git
cd stv2_beta/
```

If you are just updating the repository to the latest version (always recommended before building a docker image). Run the following command from within your local clone (under snowtire directory):

```
git pull

```

## Build Snowtire docker image

There are two ways to build the image, either with the default levels, or by specifying actual driver levels while building.

### Default drivers, connectors and scala kernel levels

The default levels are specified in the Docker file (lines starting with ARG). These levels are refreshed on a best level basis, and have been sanity tested. If you are satisfied with these levels, you can simply run the following command:

```
docker build --pull -t snowtire .
```

### Specify the driver levels while building

First check the latest clients available in the official [Snowflake documentation](https://docs.snowflake.net/manuals/release-notes/client-change-log.html#client-changes-by-version)

Once you have chosen the versions, you can pass the different versions as arguments in the docker build command:

```
docker build --pull -t snowtire . \
--build-arg odbc_version=2.21.8 \
--build-arg jdbc_version=3.12.10 \
--build-arg spark_version=2.8.1-spark_2.4 \
--build-arg snowsql_version=1.2.9 \
--build-arg almond_version=0.10.0 \
--build-arg scala_version=2.12.11 
```

**NOTE: SnowSQL CLI has the ability to [auto-upgrade](https://docs.snowflake.net/manuals/user-guide/snowsql-install-config.html#label-understanding-auto-upgrades) to the latest version available. So, you may not need to specify a higher version.**

### Build completion

You may get some warnings which are non critical, and/or expected. You can safely ignore them:
```
...
debconf: delaying package configuration, since apt-utils is not installed
...
==> WARNING: A newer version of conda exists. <==
  current version: 4.6.14
  latest version: 4.7.5

Please update conda by running

    $ conda update -n base conda
...
grep: /etc/odbcinst.ini: No such file or directory
...
grep: /etc/odbc.ini: No such file or directory
```

You should see the following message at the very end:
```
Successfully tagged snowtire:latest
```

## Running the image
```
docker run -p 8888:8888 --name spare-0 snowtire:latest
```
If the port 8888 is already taken on your laptop, and you want to use another port, you can simply change the port mapping. For example, for port 9999, it would be:
```
docker run -p 9999:8888 --name spare-1 snowtire:latest
```

You should see a message like the following the very first time you bring up this image. Copy the token value in the URL:
```
[I 23:33:42.828 NotebookApp] Writing notebook server cookie secret to /home/jovyan/.local/share/jupyter/runtime/notebook_cookie_secret
[I 23:33:43.820 NotebookApp] JupyterLab extension loaded from /opt/conda/lib/python3.7/site-packages/jupyterlab
[I 23:33:43.820 NotebookApp] JupyterLab application directory is /opt/conda/share/jupyter/lab
[I 23:33:43.822 NotebookApp] Serving notebooks from local directory: /home/jovyan
[I 23:33:43.822 NotebookApp] The Jupyter Notebook is running at:
[I 23:33:43.822 NotebookApp] http://(a8e53cbad3a0 or 127.0.0.1):8888/?token=eb2222f1a8cd14046ecc5177d4b1b5965446e3c34b8f42ad
[I 23:33:43.822 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[C 23:33:43.826 NotebookApp] 
    
    To access the notebook, open this file in a browser:
        file:///home/jovyan/.local/share/jupyter/runtime/nbserver-17-open.html
    Or copy and paste one of these URLs:
        http://(a8e53cbad3a0 or 127.0.0.1):8888/?token=eb2222f1a8cd14046ecc5177d4b1b5965446e3c34b8f42ad
```

**Note:** If you are restarting the image, and you need to retrieve the token you can retrieve it as following:

  - Retrieve its value from the docker logs as following:

  ```
  docker logs spare-0 --tail 10
  ```
 
 - Open a bash session on the docker container
 
 ```
 docker exec -it spare-0 /bin/bash
 ```
 
 Then run the following command:
 
 ```
 jupyter notebook list
 ```
 
## Accessing the image

Open a web browser on: http://localhost:8888

It will prompt you for a Password or token. Enter the token you have in the previous message.

## Working with the image

Snowtire come with 4 different small examples of python notebooks allowing to test various connectors including odbc, jdbc, spark. You will need to customize your Snowflake account name, your credentials (user/password), database name and warehouse.

You can always upload to the jupyter environment any demo notebook from the main interface. See the Upload button at the top right:

![Image](https://github.com/zoharsan/snowflake-jupyter-extras/blob/master/Notebooks.png)

These notebooks can work with the tpch_sf1 database which is provided as a sample within any Snowflake environment.

If you plan to develop new notebooks within the Docker environment, in order to avoid losing any work due to a Docker container discarded accidentally or any other container corruption, it is recommended to always keep a local copy of your work once you are done. This can be done in the Jupyter menu: File->Download as.

### Stopping and starting the docker image

Once finished, you can stop the image with the following command:
```
docker stop spare-0
```
If you want to resume work, you can start the image with the following command:
```
docker start spare-0
```

### Additional handy commands

- To delete the container. WARNING: If you do this, you will lose any notebook, and any work you have saved or done within the container.
```
docker rm spare-0
```
- To open a bash session on the docker container, which will be useful to use the snowsql interface:
```
docker exec -it spare-0 /bin/bash
```
- To copy files in the docker container:
```
docker cp <absolute-file-name> spare-0:<absolute-path-name in the container>
Example: docker cp README.md spare-0:/
```
- To list all docker containers available:
```
docker ps -a
```
- To list all docker images available:
```
docker image ls
```
- To delete a docker image:
```
docker image rm <image-id>
```
You can find out the image id in the previous list command.

### Known Issues & Troubleshooting

---
#### Stability: Notebook hangs or crashes on large data sets ####

Make sure you have enough memory allocated for your Docker Workstation, at least 4 GB. On Mac:

- Stop all your docker images (See instructions above to stop/start docker images).
- Click on the Docker Icon on the top right hand side of your Mac Menu bar.
- Select Preferences
- Select Resources
- Set CPUs to minimum of 2.
- Set Memory to 4 GB.
- Click on Apply & Restart.

---
#### Failure to connect to Snowflake when Snowflake URI has underscores "_" ####

Due to a [JDK Bug](https://bugs.openjdk.java.net/browse/JDK-8221675) in JDK 8, JDBC connection in Spark or Snowpark may fail with the following stack:

```
net.snowflake.client.jdbc.SnowflakeSQLException: JDBC driver encountered communication error. Message: Exception encountered for HTTP request: Remote host terminated the handshake.
net.snowflake.client.jdbc.RestRequest.execute(RestRequest.java:284)
net.snowflake.client.core.HttpUtil.executeRequestInternal(HttpUtil.java:496)
net.snowflake.client.core.HttpUtil.executeRequest(HttpUtil.java:441)
net.snowflake.client.core.HttpUtil.executeGeneralRequest(HttpUtil.java:408)
net.snowflake.client.core.SessionUtil.newSession(SessionUtil.java:574)
net.snowflake.client.core.SessionUtil.openSession(SessionUtil.java:279)
net.snowflake.client.core.SFSession.open(SFSession.java:435)
net.snowflake.client.jdbc.DefaultSFConnectionHandler.initialize(DefaultSFConnectionHandler.java:103)
net.snowflake.client.jdbc.DefaultSFConnectionHandler.initializeConnection(DefaultSFConnectionHandler.java:79)
net.snowflake.client.jdbc.SnowflakeConnectionV1.initConnectionWithImpl(SnowflakeConnectionV1.java:116)
net.snowflake.client.jdbc.SnowflakeConnectionV1.<init>(SnowflakeConnectionV1.java:96)
com.snowflake.snowpark.internal.ServerConnection.$anonfun$connection$1(ServerConnection.scala:132)
scala.Option.getOrElse(Option.scala:189)
com.snowflake.snowpark.internal.ServerConnection.<init>(ServerConnection.scala:130)
com.snowflake.snowpark.internal.ServerConnection$.apply(ServerConnection.scala:23)
com.snowflake.snowpark.Session$SessionBuilder.createInternal(Session.scala:896)
com.snowflake.snowpark.Session$SessionBuilder.create(Session.scala:884)
ammonite.$sess.cmd2$Helper.<init>(cmd2.sc:6)
ammonite.$sess.cmd2$.<init>(cmd2.sc:7)
ammonite.$sess.cmd2$.<clinit>(cmd2.sc:-1)
javax.net.ssl.SSLHandshakeException: Remote host terminated the handshake
sun.security.ssl.SSLSocketImpl.handleEOF(SSLSocketImpl.java:1310)
sun.security.ssl.SSLSocketImpl.decode(SSLSocketImpl.java:1151)
sun.security.ssl.SSLSocketImpl.readHandshakeRecord(SSLSocketImpl.java:1054)
sun.security.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:394)
net.snowflake.client.jdbc.internal.apache.http.conn.ssl.SSLConnectionSocketFactory.createLayeredSocket(SSLConnectionSocketFactory.java:436)
net.snowflake.client.jdbc.internal.apache.http.conn.ssl.SSLConnectionSocketFactory.connectSocket(SSLConnectionSocketFactory.java:384)
net.snowflake.client.jdbc.internal.apache.http.impl.conn.DefaultHttpClientConnectionOperator.connect(DefaultHttpClientConnectionOperator.java:142)
net.snowflake.client.jdbc.internal.apache.http.impl.conn.PoolingHttpClientConnectionManager.connect(PoolingHttpClientConnectionManager.java:376)
net.snowflake.client.jdbc.internal.apache.http.impl.execchain.MainClientExec.establishRoute(MainClientExec.java:393)
net.snowflake.client.jdbc.internal.apache.http.impl.execchain.MainClientExec.execute(MainClientExec.java:236)
net.snowflake.client.jdbc.internal.apache.http.impl.execchain.ProtocolExec.execute(ProtocolExec.java:186)
net.snowflake.client.jdbc.internal.apache.http.impl.execchain.RetryExec.execute(RetryExec.java:89)
net.snowflake.client.jdbc.internal.apache.http.impl.execchain.RedirectExec.execute(RedirectExec.java:110)
net.snowflake.client.jdbc.internal.apache.http.impl.client.InternalHttpClient.doExecute(InternalHttpClient.java:185)
net.snowflake.client.jdbc.internal.apache.http.impl.client.CloseableHttpClient.execute(CloseableHttpClient.java:83)
net.snowflake.client.jdbc.internal.apache.http.impl.client.CloseableHttpClient.execute(CloseableHttpClient.java:108)
net.snowflake.client.jdbc.RestRequest.execute(RestRequest.java:160)
net.snowflake.client.core.HttpUtil.executeRequestInternal(HttpUtil.java:496)
net.snowflake.client.core.HttpUtil.executeRequest(HttpUtil.java:441)
net.snowflake.client.core.HttpUtil.executeGeneralRequest(HttpUtil.java:408)
net.snowflake.client.core.SessionUtil.newSession(SessionUtil.java:574)
net.snowflake.client.core.SessionUtil.openSession(SessionUtil.java:279)
net.snowflake.client.core.SFSession.open(SFSession.java:435)
```

When using Snowpark, please upgrade to the latest Docker container (Updated May 19 2021) which upgrades the JDK to JDK 11. However, Spark 2.4 version doesn't support JDK 11 and is using JDK 8 within the docker. In order to circumvent this issue, replace underscores with dashes as follows:

It may fail if your URL is:
```https://ca_acme.ca-central-1.aws.snowflakecomputing.com/```
You can replace it with to make it work:
```https://ca-acme.ca-central-1.aws.snowflakecomputing.com/```

This workaround is also valid with Snowpark.

#### Spark Notebook fail when using JDK 11 ####

The May 19 update of Snowtire installs JDK 11, which is incompatible with Spark 2.4. You may see the following stack when trying to run your spark notebooks:

```
y4JJavaError: An error occurred while calling o84.showString.
: java.lang.IllegalArgumentException: Unsupported class file major version 55
	at org.apache.xbean.asm6.ClassReader.<init>(ClassReader.java:166)
	at org.apache.xbean.asm6.ClassReader.<init>(ClassReader.java:148)
	at org.apache.xbean.asm6.ClassReader.<init>(ClassReader.java:136)
	at org.apache.xbean.asm6.ClassReader.<init>(ClassReader.java:237)
	at org.apache.spark.util.ClosureCleaner$.getClassReader(ClosureCleaner.scala:49)
	at org.apache.spark.util.FieldAccessFinder$$anon$3$$anonfun$visitMethodInsn$2.apply(ClosureCleaner.scala:517)
	at org.apache.spark.util.FieldAccessFinder$$anon$3$$anonfun$visitMethodInsn$2.apply(ClosureCleaner.scala:500)
	at scala.collection.TraversableLike$WithFilter$$anonfun$foreach$1.apply(TraversableLike.scala:733)
	at scala.collection.mutable.HashMap$$anon$1$$anonfun$foreach$2.apply(HashMap.scala:134)
	at scala.collection.mutable.HashMap$$anon$1$$anonfun$foreach$2.apply(HashMap.scala:134)
	at scala.collection.mutable.HashTable$class.foreachEntry(HashTable.scala:236)
	at scala.collection.mutable.HashMap.foreachEntry(HashMap.scala:40)
	at scala.collection.mutable.HashMap$$anon$1.foreach(HashMap.scala:134)
```

If you see this error, you need to switch the default JDK to JDK 8 using the following command after open a bash session on your container (See instructions above in 'Additional Handy Commands' section):

```
root@91875ce97fb6:~/work/snowpark# sudo update-alternatives --config java
  There are 2 choices for the alternative java (providing /usr/bin/java).

    Selection    Path                                            Priority   Status
  ------------------------------------------------------------
    0            /usr/lib/jvm/java-11-openjdk-amd64/bin/java      1111      auto mode
  * 1            /usr/lib/jvm/java-11-openjdk-amd64/bin/java      1111      manual mode
    2            /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java   1081      manual mode

  Press <enter> to keep the current choice[*], or type selection number: 2
```

After doing this, restart the kernel for your notebook to pick-up the JDK 8 and it should work.

#### Python Kernel Dying ####

In case you have the Python kernel dying while running the notebook, and you want to troubleshoot the root cause, please add these lines as your first paragraph of your notebook and execute the paragraph:
```
# Debugging

import logging
import os
  
for logger_name in ['snowflake','botocore','azure']:
    logger = logging.getLogger(logger_name)
    logger.setLevel(logging.DEBUG)
    ch = logging.FileHandler('python_connector.log')
    ch.setLevel(logging.DEBUG)
    ch.setFormatter(logging.Formatter('%(asctime)s - %(threadName)s %(filename)s:%(lineno)d - %(funcName)s() - %(levelname)s - %(message)s'))
    logger.addHandler(ch)
```
This will generate a python_connector.log file where the notebook resides. Use the commands above to ssh into the image and examine the log.

---
#### Building the Docker Image fails on Windows ####

Building the docker image fails on Windows with the following errors:

```
Step 14/24 : RUN odbc_version=2.21.8 jdbc_version=3.12.10 spark_version=2.8.1-spark_2.4 snowsql_version=1.2.9 /deploy_snowflake.sh
 ---> Running in 0cfd230c3949
: not foundwflake.sh: 11: /deploy_snowflake.sh:
: not foundwflake.sh: 13: /deploy_snowflake.sh:
/deploy_snowflake.sh: 24: cd: can't cd to /
: not foundwflake.sh: 25: /deploy_snowflake.sh:
 ...loading odbc driver version 2.21.8
curl: (3) URL using bad/illegal format or missing URL
 ...loading jdbc driver version 3.12.10
: not foundwflake.sh: 28: /deploy_snowflake.sh:
curl: (3) URL using bad/illegal format or missing URL
 ...loading spark driver version 2.8.1-spark_2.4
: not foundwflake.sh: 31: /deploy_snowflake.sh:
curl: (3) URL using bad/illegal format or missing URL
 ...load SnowSQL client version 1.2.9
...
```
This is caused by Windows CRLF line ending special characters added to the deploy_snowflake.sh script causing the script to fail in the Linux Ubuntu container. Open the deploy_snowflake.sh with an Editor like Notepad++ and save the file in UNIX mode which will convert CRLF to LF line endings and rerun the docker build command.


---
#### Known Issues Log ####

Please check [known issues](known_issues.md) log for known issues with Snowtire. 
