#    - Please check the following URLs for the driver versions to pick up:
#         All drivers: https://docs.snowflake.net/manuals/release-notes/client-change-log.html#client-changes-by-version
#         ODBC:  https://sfc-repo.snowflakecomputing.com/odbc/linux/index.html
#         JDBC:  https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/
#         Spark: https://repo1.maven.org/maven2/net/snowflake/spark-snowflake_2.11
#         Note: For Spark, the docker currently uses Spark 2.4 with Scala 2.11
#    - Update lines 17 to 22 (beginning with ARG) with the correct levels to be deployed which executes deploy_snowflake.sh Script
#    - For the almond & scala kernel, please check the following link:
#         https://almond.sh/docs/quick-start-install
#    - Note: For the jupyter scala kernel, the version can be set with the variable scala_kernel_version
# Questions: Zohar Nissare-Houssen - z.nissare-houssen@snowflake.com
#

#Start from the following core stack & driver levels versions
FROM jupyter/all-spark-notebook:1c8073a927aa
USER root
ARG almond_version=0.10.9
ARG scala_kernel_version=2.12.11
ARG odbc_version=2.23.2
ARG jdbc_version=3.13.3
ARG spark_version=2.8.5-spark_2.4
ARG snowsql_version=1.2.14
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y libssl-dev libffi-dev && \
    apt-get install -y vim && \
    apt-get install -y openjdk-11-jdk
RUN update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java
RUN sudo -u jovyan /opt/conda/bin/curl -Lo coursier https://git.io/coursier-cli
RUN chown -R jovyan:users /home/jovyan/coursier && chmod +x /home/jovyan/coursier
RUN sudo -u jovyan /home/jovyan/coursier launch --fork almond:$almond_version --scala $scala_kernel_version -- --install
COPY ./kernel.json /home/jovyan/.local/share/jupyter/kernels/scala/
RUN chown jovyan:users /home/jovyan/.local/share/jupyter/kernels/scala/kernel.json
RUN sudo -u jovyan /opt/conda/bin/python -m pip install --upgrade pip
RUN sudo -u jovyan /opt/conda/bin/python -m pip install --upgrade pyarrow
RUN sudo -u jovyan /opt/conda/bin/python -m pip install --upgrade snowflake-connector-python[pandas]
RUN sudo -u jovyan /opt/conda/bin/python -m pip install --upgrade snowflake-sqlalchemy
RUN sudo -u jovyan /opt/conda/bin/python -m pip install --upgrade plotly
RUN sudo -u jovyan /opt/conda/bin/python -m pip install --upgrade nbformat
RUN sudo -u jovyan /opt/conda/bin/python -m pip install jupyter_contrib_nbextensions
RUN conda install pyodbc
RUN conda install -c conda-forge jupyterlab-plotly-extension --yes
RUN apt-get install -y iodbc libiodbc2-dev libssl-dev
COPY ./deploy_snowflake.sh /
RUN chmod +x /deploy_snowflake.sh
RUN /deploy_snowflake.sh
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
RUN sudo -u jovyan /opt/conda/bin/jupyter contrib nbextension install --user
RUN sudo -u jovyan /opt/conda/bin/jupyter nbextensions_configurator enable --user
RUN sudo -u jovyan /opt/conda/bin/jupyter nbextension enable collapsible_headings/main
RUN sudo -u jovyan /opt/conda/bin/jupyter nbextension enable execute_time/ExecuteTime
RUN sudo -u jovyan /opt/conda/bin/jupyter nbextension enable codefolding/main
