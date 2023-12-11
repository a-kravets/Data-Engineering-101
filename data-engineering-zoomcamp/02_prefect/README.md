# Run Prefect Locally

Install Perfect with `pip install prefect -U`

A [**flow**](https://docs.prefect.io/latest/concepts/flows/) is the most basic Prefect object that is a container for workflow logic and allows you to interact and understand the state of the workflow. Flows are like functions, they take inputs, preform work, and return an output. We can start by using the `@flow` decorator to a main_flow function.

Flows contain tasks. [**Tasks**](https://docs.prefect.io/latest/concepts/tasks/) are not required for flows but tasks are special because they receive metadata about upstream dependencies and the state of those dependencies before the function is run, which gives you the opportunity to have a task wait on the completion of another task before executing.

Run the flow and then open it as visual:

* `python ingest_data_perfect.py` runs the flow
* `python server start` launches the UI

This should be default but if your having problem or just want to make sure you set the prefect config to point to the api URL. This is especially important if you are going to host the URL somewhere else and need to change the url for the API that your flows are communicating with.

* `prefect config set PREFECT_API_URL="http://127.0.0.1:4200/api"`

By opening up localhost we can see the Prefect UI, which gives us a nice dashboard to see all of our flow run history.

[**Blocks**](https://docs.prefect.io/latest/concepts/blocks/) are a primitive within Prefect that enable the storage of configuration and provide an interface with interacting with external systems. There are several different types of blocks you can build, and you can even create your own. Block names are immutable so they can be reused across multiple flows. Blocks can also build upon blocks or be installed as part of Intergration collection which is prebuilt tasks and blocks that are pip installable. For example, a lot of users use the SqlAlchemy

# ETL with Google Cloud Platform and Prefect

Files:
* `etl_web_to_gcs.py` gets the data from the web, saves it locally, does some cleaning and stores the result in Google Storage bucket
* `etl_gcs_to_bq.py` does the same thing, but also saves data to BigQuery
* `ingest_data_prefect_parameterized.py` uses parameters instead of hard-coded values

# Deployment

In order to deploy our flow, we run `prefect deployment build ./ingest_data_prefect_parameterized.py:etl_parent_flow -n "Parameterized ETL"`, where:

* `./ingest_data_prefect_parameterized.py` is a path to the flow
* `etl_parent_flow` is the entry point (there can be multiple flows in a file)
* `"Parameterized ETL"` is a name of the deployment

By running `prefect deployment build` Prefect will create a `yaml` file. In our case it's called `etl_parent_flow-deployment.yaml`, which specifies params and options for Prefect to deploy.

After that we may run `prefect deployment apply etl_parent_flow-deployment.yaml`

To set the flow runs from this deployment to be active, start an agent that pulls work from the 'default' work queue by running `prefect agent start --pool "default-agent-pool" --work-queue "default"`, where

* `'default'` is the name of a work queue
* `"default-agent-pool"` is the name of an agent

It will launch the flow, will stay active and will follow a schedule of flow runs, if there is any.

We may set [**schedules**](https://docs.prefect.io/latest/concepts/schedules/) in multiple ways:

* Through the Prefect UI
* Via a the `cron`, `interval`, or `rrule` parameters if building your deployment via the serve method of the Flow object or the serve utility for managing multiple flows simultaneously
* If using worker-based deployments
* Through the interactive `prefect deploy` command. With the `deployments` -> `schedule` section of the `prefect.yaml` file
