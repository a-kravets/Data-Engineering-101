from prefect.deployments import Deployment
# import the main flow from our file
from ingest_data_prefect_parameterized import etl_parent_flow
from prefect.infrastructure.container import DockerContainer

docker_block = DockerContainer.load("zoom")

docker_dep = Deployment.build_from_flow(
    flow=etl_parent_flow,
    name="docker-flow",
    # we specify that it'll run by docker, cloud options available
    infrastructure=docker_block,
)


if __name__ == "__main__":
    docker_dep.apply()