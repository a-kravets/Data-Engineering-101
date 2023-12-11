**Execution steps**

* `terraform init` initializes & configures the backend, installs plugins/providers, & checks out an existing configuration from a version control
* `terraform plan` matches/previews local changes against a remote state, and proposes an Execution Plan.
* `terraform apply` asks for approval to the proposed plan, and applies changes to cloud
* `terraform destroy` removes your stack from the Cloud
