Infrastructure as Code. Why you need it.
##############################################
:date: 2019-11-25 14:20
:author: Aliaksei Maiseyeu
:tags: non-technical
:slug: infrastructure_as_code


Dawn of the Infrastructure as Code
----------------------------------

At first, when the trees were taller and the grass was green, it was
only bare-metal. Each server was a separate physical unit.
Those were the times of simple solutions: you connect the server to the
network and power source, connect via telnet / ssh, install all the
necessary software, set up cron-jobs for alerts and you're done.

Then it was time for virtualization. From the early 2000s, the IT industry
began to plunge into this amazing world, without even assuming how far this will go.

In the beginning, the approach used when working with bare-metal
was still good. Only instead of physical servers became virtual.
Over time, the number of servers has grown. Old methods began to take
too much time. This situation stimulated the appearance of
provisioners, which simplified and accelerated the process of setting
up servers and installing software.

And now we live in era of cloud computing. Today’s engineers 
may need a dozen or a hundred servers to accomplish business goals.
Neednes of new approach became critical.


Meet Infrastructure as Code
---------------------------

Definition:

    Infrastructure as code (IaC) is the process of managing and provisioning
    computer data centers through machine-readable definition files, rather than
    physical hardware configuration or interactive configuration tools. [#]_

    --Wikipedia

Abbility to manage infrastructure as code provides a lot of important benefits!
From this point we can:
- versioning the infrastructure
- cover it with tests
- scale number of environments with the speed of light


All this features is available due to of IaC concept main targets:

:reduce price: now you utilize your computing resources with highest efficiency
:increase velocity: engineers spending more time on the improvements and development
                    instead of the routine tasks
:decrease risks: replacing manual operations with automation makes chance
                 of human error pretty low (if your automation covered by tests ¯\\_(ツ)_/¯ )


IaC tools
---------

So, you descide to implement Infrastructure as Code.

Now we should choose proper tool, that will match requirements of your project.

Google Cloud Deployment Manager
===============================

Deployment Manager is an infrastructure deployment service that
automates the creation and management of Google Cloud Platform (GCP)
resources. Write flexible template and configuration files and use them
to create deployments that have a variety of GCP services, such as Cloud
Storage, Compute Engine, and Cloud SQL, configured to work together.

Pros:

-  Developed and maintained by cloud provider

Cons:

-  Works only with GCP

Azure Resource Manager
======================

Azure Resource Manager is the deployment and management service for
Azure. It provides a management layer that enables you to create,
update, and delete resources in your Azure subscription. You use
management features, like access control, locks, and tags, to secure and
organize your resources after deployment.

Pros:

-  Developed and maintained by cloud provider

Cons:

-  Works only with Azure

AWS CloudFormation
==================

AWS CloudFormation provides a common language for you to describe and
provision all the infrastructure resources in your cloud environment.
CloudFormation allows you to use programming languages or a simple text
file to model and provision, in an automated and secure manner, all the
resources needed for your applications across all regions and accounts.
This gives you a single source of truth for your AWS resources.

Pros:

-  Developed and maintained by cloud provider

Cons:

-  Works only with AWS

Chef
====

Chef Infra is a powerful automation platform that transforms
infrastructure into code. Whether you’re operating in the cloud,
on-premises, or in a hybrid environment, Chef Infra automates how
infrastructure is configured, deployed, and managed across your network,
no matter its size.

Pros:

-  Cloud agnostic

Cons:

-  Requires Chef Infra Server to store cookbooks, the policies that are
   applied to nodes, and metadata that describes each registered node
   that is being managed by Chef

Terraform
=========

Terraform is a tool for building, changing, and versioning
infrastructure safely and efficiently. Terraform can manage existing and
popular service providers as well as custom in-house solutions.
Configuration files describe to Terraform the components needed to run a
single application or your entire datacenter. Terraform generates an
execution plan describing what it will do to reach the desired state,
and then executes it to build the described infrastructure. As the
configuration changes, Terraform is able to determine what changed and
create incremental execution plans which can be applied.

Pros:

-  Cloud agnostic
-  Huge community

Cons:

-  Terraform state is key and if corrupted it can't be restored
-  No build-in rollback capability


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

Significant thing should be mentioned: as soon as your IaC will
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

Common terraform examples
-------------------------

TBD


.. [#] Wittig, Andreas; Wittig, Michael (2016). Amazon Web Services in Action. Manning Press. p. 93. ISBN 978-1-61729-288-0.
.. [#] https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c