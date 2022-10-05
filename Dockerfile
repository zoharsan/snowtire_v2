#    - Please check the following URLs for the driver versions to pick up:
#         All drivers: https://docs.snowflake.net/manuals/release-notes/client-change-log.html#client-changes-by-version
#         ODBC:  https://sfc-repo.snowflakecomputing.com/odbc/linux/index.html
#         JDBC:  https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/
#         Spark: https://repo1.maven.org/maven2/net/snowflake/spark-snowflake_2.12/
#         Note: For Spark, the docker currently uses Spark 3.1.1 with Scala 2.12.10
#    - Update lines 17 to 22 (beginning with ARG) with the correct levels to be deployed which executes deploy_snowflake.sh Script
#    - For the almond & scala kernel, please check the following link:
#         https://almond.sh/docs/quick-start-install
#    - Note: For the jupyter scala kernel, the version can be set with the variable scala_kernel_version
# Questions: Zohar Nissare-Houssen - z.nissare-houssen@snowflake.com
#

#Start from the following core stack & driver levels versions
FROM jupyter/all-spark-notebook:spark-3.3.0

#Setting up default levels for all drivers and connectors
#You can either customize levels in the section below or add as arguments while building the docker

USER root
ARG almond_version=0.10.9
ARG scala_kernel_version=2.12.11
ARG odbc_version=2.25.5
ARG jdbc_version=3.13.9
ARG spark_version=2.11.0-spark_3.3
ARG snowsql_version=1.2.23

#Installing base OS packages prerequisites including jdk 8 and jdk 11 versions
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y libssl-dev libffi-dev && \
    apt-get install -y vim && \
    apt-get install -y iodbc libiodbc2-dev && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y openjdk-11-jdk

#Installing Snowpark Scala Almond Jupyter Kernel
RUN update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java
RUN sudo -u jovyan /opt/conda/bin/curl -Lo coursier https://git.io/coursier-cli
RUN chown -R jovyan:users /home/jovyan/coursier && chmod +x /home/jovyan/coursier
RUN sudo -u jovyan /home/jovyan/coursier launch --fork almond:$almond_version --scala $scala_kernel_version -- --install
COPY ./kernel.json /home/jovyan/.local/share/jupyter/kernels/scala/
RUN chown jovyan:users /home/jovyan/.local/share/jupyter/kernels/scala/kernel.json

#Creating conda Environment with Python 3.8 for Snowpark for Python called pysnowpark
USER jovyan
RUN conda create -n pysnowpark -c https://repo.anaconda.com/pkgs/snowflake python=3.8

#Setting up default Python environment to support pyspark and snowflake python connector
RUN conda install -c conda-forge jupyterlab-plotly-extension --yes
SHELL ["conda", "run", "/bin/bash", "-c"]
RUN pip install --upgrade pip
RUN pip install --upgrade pyarrow
RUN pip install --upgrade snowflake-connector-python[pandas]
RUN pip install --upgrade snowflake-sqlalchemy
RUN pip install --upgrade plotly
RUN pip install --upgrade pyodbc

#Setting up Snowpark Python conda environment 
SHELL ["conda", "run", "-n", "pysnowpark", "/bin/bash", "-c"]
RUN pip install --user ipykernel
RUN python -m ipykernel install --user --name=pysnowpark
RUN pip install pandas nbformat plotly scikit-plot pyarrow==8.0.0 seaborn matplotlib
RUN pip install snowflake-snowpark-python

#Deploying Snowflake Connectors and Drivers
USER root
SHELL ["/bin/bash", "-c"]
COPY ./deploy_snowflake.sh /
RUN chmod +x /deploy_snowflake.sh
RUN /deploy_snowflake.sh

#Deploying Sample Scripts
RUN mkdir /home/jovyan/samples
COPY ./pyodbc.ipynb /home/jovyan/samples
COPY ./Python.ipynb /home/jovyan/samples
COPY ./spark.ipynb /home/jovyan/samples
COPY ./SQLAlchemy.ipynb /home/jovyan/samples
RUN chown -R jovyan:users /home/jovyan/samples
RUN sudo -u jovyan /opt/conda/bin/jupyter trust /home/jovyan/samples/pyodbc.ipynb
RUN sudo -u jovyan /opt/conda/bin/jupyter trust /home/jovyan/samples/Python.ipynb
RUN sudo -u jovyan /opt/conda/bin/jupyter trust /home/jovyan/samples/spark.ipynb
RUN sudo -u jovyan /opt/conda/bin/jupyter trust /home/jovyan/samples/SQLAlchemy.ipynb
