Infrastructure as Code. Why you need it.
##############################################
:date: 2019-12-03 19:00
:author: Aliaksei Maiseyeu
:tags: technical
:slug: infrastructure_as_code


Dawn of the Infrastructure as Code
----------------------------------

At first, when the trees were taller and the grass was green, it was
only bare-metal. Each server was a separate physical unit.
Those were the times of simple solutions: you connect the server to the
network and power source, login via telnet / ssh, install all the
necessary software, set up cron-jobs for alerts and you're done!

Then it came time for virtualization. From the early 2000s, the IT industry
began to plunge into this amazing world, without even assuming how far this will go.

In the beginning, the same approach as when working with bare-metal
was still good. Only instead of physical servers you had virtual ones.
Over time, the number of servers has grown. Old methods began to take
too much time. This situation stimulated the appearance of
provisioners, which simplified and accelerated the process of setting
up servers and installing software.

And now we live in the era of cloud computing. Today’s engineers 
may need a dozen or a hundred servers to accomplish business goals.
Need for new approach became critical.


Meet Infrastructure as Code
---------------------------

Definition:

    Infrastructure as code (IaC) is the process of managing and provisioning
    computer data centers through machine-readable definition files, rather than
    physical hardware configuration or interactive configuration tools. [#]_

    --Wikipedia

Abbility to manage infrastructure as code provides a lot of important benefits!
From this point we can:

* infrastructure versioning
* cover it with tests
* scale number of environments with the speed of light


All this features is available due to of IaC concept main targets:

- **reduce price**: now you utilize your computing resources with highest efficiency
- **increase velocity**: engineers spending more time on the improvements and development
  instead of the routine tasks
- **decrease risks**: replacing manual operations with automation makes chance
  of human error pretty low (if your automation covered by tests ¯\\_(ツ)_/¯ )


IaC tools
---------

So, you descide to implement Infrastructure as Code.

Now we should choose proper tool, that will match requirements of your project.

Cloud vendor's tools short-list:

- Google Cloud Deployment Manager
- Azure Resource Manager
- AWS CloudFormation


3rd party tools short-list:

- Chef
- Terraform


Advantage of 3rd party tools is possibility to manage several clouds.


Technical diferences of IaC tools
---------------------------------

.. epigraph::

   *«Choose wisely, Luke»*

   -- Yoda, Jedi Master

From technical perspective, IaC tools realisations have several variations:

* Mutable Infrastructure vs Immutable Infrastructure
* Procedural vs Declarative
* Master vs Masterless
* Agent vs Agentless

Each of this options has strength and weakness. [#]_

Along with that, Terraform aims to be industry-wide acknowledged mainstream as of now (Dec 2019)

Significant point should be mentioned: as soon as your IaC will
describe more than several dozen of resources, migration on another
tool become the pain somewhere little lower the back and there is no
any automated tool to relieve this pain.

Few words about Terraform
-------------------------

Modules
=======

A module is a container for multiple resources that are used together.
Every Terraform configuration has at least one module, known as its root
module, which consists of the resources defined in the .tf files in the
main working directory.

A module can call other modules, which lets you include the child
module's resources into the configuration in a concise way. Modules can
also be called multiple times, either within the same configuration or
in separate configurations, allowing resource configurations to be
packaged and re-used.

Here is code example that allows to create basic network infrastrustire
in AWS:
::

    module "core" {
      source = "github.com/lean-delivery/tf-module-aws-core.git?ref=1.0.0"
    
      project            = "amazing"
      environment        = "production"
      availability_zones = ["us-east-1a", "us-east-1b"]
      vpc_cidr           = "10.0.0.0/8"
      private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
      public_subnets     = ["10.0.3.0/24", "10.0.4.0/24"]
    
      database_subnets             = var.database_subnets
      create_database_subnet_group = true
    
      enable_nat_gateway = true
    }


Workspaces
==========

Each Terraform configuration has an associated backend that defines how
operations are executed and where persistent data such as the Terraform
state are stored. The persistent data stored in the backend belongs to a
workspace. Initially the backend has only one workspace, called
"default", and thus there is only one Terraform state associated with
that configuration.

Certain backends support multiple named workspaces, allowing multiple
states to be associated with a single configuration. The configuration
still has only one backend, but multiple distinct instances of that
configuration to be deployed without configuring a new backend or
changing authentication credentials.

Multiple workspaces are currently supported by the following backends:

- AzureRM
- Hashicorp Consul
- Google Compute Storage
- Local File system
- Manta
- Postgres
- Terraform Remote
- AWS S3

Terraservices
=============

Terraservices concept was presented by Nicki Watt on `"Hashidays London
2017" <https://www.hashicorp.com/resources/evolving-infrastructure-terraform-opencredo>`__.

    And the name is akin to microservices because I do think there's
    some similarity in the evolution of how we got here. So, the
    characteristics of Terraservices is that we have, we break up
    components up into logical modules and we manage them separately. So
    now we move to having one state file per component, rather than per
    environment. And typically, if you haven't done so already, you will
    start moving to a distributed or a mode state type of setup.


"Terraform power, on!"
----------------------

After almost two years of using Terraform we finally found our best practices.
And now we will share it with you.


Assumption
    Let's use in this example AWS as cloud provider


Classic case
============

We should prepare infrastructure for new service. That includes:

- several EC2 instances for backend and frontend
- some of this instances should be balanced with ALB
- RDS
- VPC for all this stuff with subnets, routing tables, etc.


Solution
========

Assumption
    Let's use in this example AWS S3 as a storage for Terraform state files


No one like meaningless duplication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In our approach we use data inheritance from one terraservice to another.
It is possible with Terraform data source ``terraform_remote_state``.
Throu it we can recive any data, outputed in terraservices that already applied. As a result,
in each new terraservice we should manually define only few variables, that are specific for it.


Divide and rule
~~~~~~~~~~~~~~~

According to Terraservices concept, we divide our Terraform code
into several groups: ::

    0. terraform state storage infrastructure
    1. core infra: VPC, Subnets, routing tables, etc.
    2. common resources
        * bastion instance (if needed)
        * RDS
        * network connectivity (if needed)
    3. infrastructure for our new service

Last point could contain several separate Terraservices, depending 
on your target infrastructure: ::

    0. terraform state storage infrastructure (S3 and DynamoDB table)
    1. core infra (VPC, Subnets, routing tables, etc.)
    2. common resources
        * bastion instance (if needed)
        * RDS
        * network connectivity (if needed)
    3. infrastructure for our new service
        * shared resources
        * service's backend
        * service's frontend


Notice
    If you want to separate Production and non-Production environments 
    by placing them in different accounts you should move Terraform
    backend configuration from ``*.tf`` files to the separate ``*.hcl`` files.
    This allows you to choose required backend on ``terraform init`` step:

    ``[user@host ~] $ terraform init -backend-config=/path/to/your/tf_backend_config.hcl``

Catalog tree in your repository will looks like: ::

    /repo_folder
    ├── 0_terraform_infra
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── terraform.tfstate.d
    │   │   ├── dev
    │   │   │   ├── terraform.tfstate
    │   │   │   └── terraform.tfstate.backup
    │   │   └── prod
    │   │       ├── terraform.tfstate
    │   │       └── terraform.tfstate.backup
    │   ├── tfvars
    │   │   ├── dev.tfvars
    │   │   └── prod.tfvars
    │   ├── variables.tf
    │   └── versions.tf
    ├── 1_core
    │   ├── main.tf
    │   ├── output.tf
    │   ├── tfvars
    │   │   ├── dev-us-east-1.tfvars
    │   │   └── prod-eu-west-1.tfvars
    │   ├── variables.tf
    │   └── versions.tf
    ├── 2_bastion
    ├── 2_database
    ├── 2_network_connectivity_vpn
    ├── 3.1_shared_resources
    ├── 3.2_backend_infra
    ├── 3.2_frontend_infra
    ├── dev.hcl
    └── prod.hcl

Attentive readers may ask: "Why you store tfstate files for 0_terraform_infra in your git repository?"
There is an answer: code in 0_terraform_infra perform creation of S3 for our Terraform backend and 
untill it not exist we have no any other place to store tfstate files. This files doesn't contain
any sensetive data so we don't breaks git best practices (I mean "never store any secrets in your repository").

Also ``0_terraform_infra`` creates Terraform backend config file (``prod.hcl``, ``dev.hcl``) which will be used
for all futhure terraservices. Name of file will be generated based on workspace name.


"By the power of Worspaces!"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Allright, we have Terraform code for our infrastructure. But it should manage several environments, prod and dev, at least.
Terraform workspaces literally designed for this!
But first of all let's agree about naming convention.

Assumption
    Workspace name will contain environment name and AWS Region name, eg ``prod-eu-west-1`` and ``dev-us-east-1``.

For ``prod`` and ``dev`` environments we should use different input values, thats why each environment should have separate ``*.tfvars`` file.
Let's name they as according worspace name to avoid confusion: ``prod-eu-west-1.tfvars`` and ``dev-us-east-1.tfvars``.

Setup sequence example for ``1_core``: ::

    [user@host 1_core] $ terraform init -backend-config=../dev.hcl                  # Initialize backend for dev environment
    [user@host 1_core] $ terraform workspace new dev-us-east-1                      # Create new workspace for dev environment
    [user@host 1_core] $ terraform apply -var-file=tfvars/dev-us-east-1.tfvars      # Create dev infrastructure by applying Terraform code
    [user@host 1_core] $ rm -rf .terraform                                          # Remove backend configuration for dev env
    [user@host 1_core] $ terraform init -backend-config=../prod.hcl                 # Initialize backend for production environment
    [user@host 1_core] $ terraform workspace new prod-eu-west-1                     # Create new workspace for production environment
    [user@host 1_core] $ terraform apply -var-file=tfvars/prod-eu-west-1.tfvars     # Create prod infrastructure by applying Terraform code


"Infrastructure, assemble!"
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Using all described hints gives you flexible control on each level of
your environments. Competent separation of your infrastructure code
will allow you update any part of infrastructure safely, with minimum
risks and lowest affect on other parts of service.


Sources
-------

.. [#] Wittig, Andreas; Wittig, Michael (2016). Amazon Web Services in Action. Manning Press. p. 93. ISBN 978-1-61729-288-0.
.. [#] https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c
