# Known issues / Change Log / Gotchas

#### 2022-10-05
- ZN: Overall Image refresh with latest drivers and connectors as of date.
- ZN: Spark upgrade to Spark 3.3.0
- ZN: Support for Snowpark for Python through pysnowpark jupyter kernel
- ZN: Support for Snowpark for Scala through Scala jupyter kernel

#### 2021-05-19
- ZN: Upgraded to JDK 11

#### 2021-05-18
- ZN: Fixed spark version in Dockerfile causing issues downloading Spark Driver
- ZN: Tested latest drivers as of to date and updated Dockerfile.

#### 2020-09-14
- ZN: Tested latest drivers as of to date and updated Dockerfile.
- ZN: Fixed line 26 to remove libpq-dev to prevent the following error:

```E: Failed to fetch http://security.ubuntu.com/ubuntu/pool/main/p/postgresql-10/libpq5_10.12-0ubuntu0.18.04.1_amd64.deb  404  Not Found [IP: XXXXX 80]
E: Failed to fetch http://security.ubuntu.com/ubuntu/pool/main/p/postgresql-10/libpq-dev_10.12-0ubuntu0.18.04.1_amd64.deb  404  Not Found [IP: XXXXX 80]
E: Unable to fetch some archives, maybe run apt-get update or try with --fix-missing?
The command '/bin/sh -c apt-get install -y iodbc libiodbc2-dev libpq-dev libssl-dev' returned a non-zero code: 100
```

#### 2020-07-30:

- ZN: Added conda install of jupyterlab-plotly-extension to allow plotly visualizations when using jupyterlab mode. Note that this will require a restart of your web browser for the change to take effect.
- ZN: Tested latest drivers as of to date and updated Dockerfile.


#### 2020-04-20:

- ZN: Fixed Dockerfile to pull the pandas optimized connector for snowflake (snowflake-connector-python[pandas]).
- ZN: Tested latest drivers as of to date, including latest Spark Optimized driver version 2.7 and updated Dockerfile.

#### 2019-02-14:

- ZN: SnowSQL CLI version 1.2.4 has deployment issues which will be fixed in 1.2.5. As a workaround, just build the docker with 1.2.2, and launching SnowSQL will auto-upgrade the image.
- PG: To allow reads against GCP, add the following option to the Spark connector:
```
'use_copy_unload':'false'
```

#### 2019-02-13:

- ZN: Jupyter-Stacks latest image updated on 02/11 upgraded Spark to 2.4.5 version which breaks pyspark. Fixed Dockerfile to pick-up last working version.
