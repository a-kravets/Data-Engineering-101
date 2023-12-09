# Run Prefect Locally

Install Perfect with `pip install prefect -U`

A [**flow**](https://docs.prefect.io/latest/concepts/flows/) is the most basic Prefect object that is a container for workflow logic and allows you to interact and understand the state of the workflow. Flows are like functions, they take inputs, preform work, and return an output. We can start by using the @flow decorator to a main_flow function.

Flows contain tasks. [**Tasks**](https://docs.prefect.io/latest/concepts/tasks/) are not required for flows but tasks are special because they receive metadata about upstream dependencies and the state of those dependencies before the function is run, which gives you the opportunity to have a task wait on the completion of another task before executing.

Run the flow and then open it as visual:

* `python ingest_data_perfect.py` runs the flow
* `python server start` launches the UI

This should be default but if your having problem or just want to make sure you set the prefect config to point to the api URL. This is especially important if you are going to host the URL somewhere else and need to change the url for the API that your flows are communicating with.

* `prefect config set PREFECT_API_URL="http://127.0.0.1:4200/api"`

By opening up localhost we can see the Prefect UI, which gives us a nice dashboard to see all of our flow run history.

[**Blocks**](https://docs.prefect.io/latest/concepts/blocks/) are a primitive within Prefect that enable the storage of configuration and provide an interface with interacting with external systems. There are several different types of blocks you can build, and you can even create your own. Block names are immutable so they can be reused across multiple flows. Blocks can also build upon blocks or be installed as part of Intergration collection which is prebuilt tasks and blocks that are pip installable. For example, a lot of users use the SqlAlchemy

# ETL with Google Cloud Platform and Prefect
