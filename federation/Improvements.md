$ time terraform destroy .tmp (deletion of network routes manually in parallel)
Apply complete! Resources: 0 added, 0 changed, 53 destroyed.

real	3m39.482s
user	0m2.332s
sys	    0m1.495s

$ time terraform apply .tmp
Apply complete! Resources: 56 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

Outputs:

cluster1-kubernetes-master-ip = 104.154.16.167
cluster2-kubernetes-master-ip = 104.197.127.101
cluster3-kubernetes-master-ip = 146.148.98.209

real	7m26.405s
user	0m7.535s
sys	    0m1.228s
