Infrastructure as Code. Why you need it.
##############################################
:date: 2019-12-03 19:00
:author: Aliaksei Maiseyeu
:tags: technical
:slug: infrastructure_as_code


Dawn of the Infrastructure as Code
----------------------------------

At first, when the trees were taller and the grass was green, it was only
bare-metal. Each server was a separate physical unit. Those were the times
of simple solutions: you connected the server to the network and power
source, logged in via telnet / ssh, installed all the necessary software,
set up cron-jobs for alerts and you were done!

Then it came time for virtualization. From the early 2000s, the IT industry
began to plunge into this amazing world, without even assuming how far it
would go.

In the beginning, the same approach used to work with bare-metal was
still good. The only difference was that you had virtual servers instead
of physical ones. Gradually, the number of servers grew. Old methods began
to take too much time. This situation stimulated the appearance of provisioners,
which simplified and accelerated the process of setting up servers and 
installing software.

Now we live in the era of cloud computing. Today’s engineers may need dozens
or hundreds of servers to accomplish business goals. Need for a new approach
has become critical.



Meet Infrastructure as Code
---------------------------

Definition:

    Infrastructure as code (IaC) is the process of managing and provisioning
    computer data centers through machine-readable definition files, rather than
    physical hardware configuration or interactive configuration tools. [#]_

    --Wikipedia

Ability to manage infrastructure as code provides a lot of important benefits!
From this point we can:

* infrastructure versioning
* cover it with tests
* scale number of environments with the speed of light


All these features are available thanks to IaC concept main targets, aimed to:

- **reduce price**: now you utilize your computing resources with the highest efficiency
- **increase velocity**: engineers can spend more time on improvements and development
  instead of routine tasks
- **decrease risks**: replacing manual operations with automation reduces a chance
  of human error (if your automation is covered by tests ¯\\_(ツ)_/¯ )


IaC tools
---------

So, you decide to implement Infrastructure as Code.

Now we should choose a proper tool that will match the requirements of your project.

Cloud vendor's tools short-list:

- Google Cloud Deployment Manager
- Azure Resource Manager
- AWS CloudFormation


3rd party tools short-list:

- Chef
- Terraform


The advantage of the 3rd party tools is a possibility to manage several clouds.


Technical differences of IaC tools
----------------------------------

.. epigraph::

   *«Choose wisely, Luke»*

   -- Yoda, Jedi Master

From the technical perspective, IaC tools implementation has several variations:

* Mutable Infrastructure vs Immutable Infrastructure
* Procedural vs Declarative
* Master vs Masterless
* Agent vs Agentless

Each of these options has its strengths and weaknesses. [#]_

Along with that, Terraform aims to be an industry-wide acknowledged mainstream as of today (Dec 2019).
It’s important to mention the following: as soon as your IaC will describe more
than several dozens of resources, migration to another tool becomes the pain
somewhere a little lower than the back. And there is no automated tool to
relieve this pain.


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

Here is a code example that allows to create basic network infrastructure
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

More useful Terraform modules can be found Lean Delivery project on GitHub:

https://github.com/lean-delivery


Workspaces
==========

Each Terraform configuration has an associated back-end that defines how
operations are executed and where persistent data such as the Terraform
state is stored. The persistent data stored in the back-end belongs to a
workspace. Initially, the back-end has only one workspace called
"default", and thus, there is only one Terraform state associated with
this configuration.

Certain back-ends support multiple named workspaces, allowing multiple
states to be associated with a single configuration. The configuration
still has only one back-end, but multiple distinct instances of that
configuration can be deployed without configuring a new back-end or
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

After almost two years of using Terraform we have finally found our
best practices. And now we will share them with you.


Assumption
    Let's use AWS as cloud provider in this example


Classic case
============

We should prepare infrastructure for a new service. That includes:

- several EC2 instances for back-end and frontend
- some of these instances should be balanced with ALB
- RDS
- VPC for all this stuff with subnets, routing tables, etc.


Solution
========

Assumption
    In this example let's use AWS S3 as a storage for Terraform state files


No one likes meaningless duplication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In our approach we use data inheritance from one terraservice to another.
It is possible with Terraform data source ``terraform_remote_state``.
Through it we can receive any data, outputted in terraservices that have
already been applied. As a result, in every new terraservice we should
manually define only a few variables that are specific for it.


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

The last point could contain several separate Terraservices, depending
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
    by placing them in different accounts, you should move Terraform
    backend configuration from ``*.tf`` files to the separate ``*.hcl`` files.
    It allows you to choose required back-end on ``terraform init`` step:

    ``[user@host ~] $ terraform init -backend-config=/path/to/your/tf_backend_config.hcl``

The catalog tree in your repository will look this:

.. image:: {filename}/images/infrastructure_as_code_file_tree.png

Some readers may ask: "Why do you store tfstate files for ``0_terraform_infra`` in your git repository?"
There is an answer: code in ``0_terraform_infra`` performs the creation of S3 for our Terraform backend,
and until it doesn’t exist we have no other place to store tfstate files. These files don’t contain
any sensitive data, so we don't break git best practices (I mean "never store any secrets in your repository").

Also ``0_terraform_infra`` creates a Terraform backend config file (``prod.hcl``, ``dev.hcl``), which will be used
for all future terraservices. A name of the file will be generated based on the workspace name.

"By the power of Workspaces!"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Alright, we have a Terraform code for our infrastructure. But it should manage several environments, prod and dev, at least.
Terraform workspaces are designed right for this!
But first, let's agree on the naming convention.

Assumption
    Workspace name will contain the environment name and AWS Region name, eg ``prod-eu-west-1`` and ``dev-us-east-1``.

For ``prod`` and ``dev`` environments we should use different input values, that’s why each environment should have a separate ``*.tfvars`` file. 
Let's name them according to the workspace name to avoid confusion: ``prod-eu-west-1.tfvars`` and ``dev-us-east-1.tfvars``.


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

Using all the described hints, you’ll get flexible control on each level of 
your environments. Competent separation of your infrastructure code
will allow you to update any part of the infrastructure safely, with minimum
risks and lowest effect on other parts of the service.

Sources
-------

.. [#] Wittig, Andreas; Wittig, Michael (2016). Amazon Web Services in Action. Manning Press. p. 93. ISBN 978-1-61729-288-0.
.. [#] https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c
