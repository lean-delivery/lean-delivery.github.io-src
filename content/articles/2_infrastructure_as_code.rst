Infrastructure as Code. Why you need it.
##############################################
:date: 2019-08-14 13:50
:author: Aliaksei Maiseyeu
:tags: non-technical
:slug: infrastructure_as_code

Problem statement
-----------------

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

To be continued...

IaC tools
---------

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

Why we choose terraform
-----------------------

`No one like double work
=) <https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c>`__

Terraservices / Workspaces / Modules
------------------------------------

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

Multiple workspaces are currently supported by the following backends: -
AzureRM - Hashicorp Consul - Google Compute Storage - Local File system
- Manta - Postgres - Terraform Remote - AWS S3

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
