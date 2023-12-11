**Declarations**

* `provider` adds a set of resource types and/or data sources that Terraform can manage. The Terraform Registry is the main directory of publicly available providers from most major infrastructure platforms.
* `resource` is a set of blocks to define components of your infrastructure. Project modules/resources: `google_storage_bucket`, `google_bigquery_dataset`, `google_bigquery_table`
* `variable` & `locals` are runtime arguments and constants

**Execution steps**

* `terraform init` initializes & configures the backend, installs plugins/providers, & checks out an existing configuration from a version control
* `terraform plan` matches/previews local changes against a remote state, and proposes an Execution Plan.
* `terraform apply` asks for approval to the proposed plan, and applies changes to cloud
* `terraform destroy` removes your stack from the Cloud
