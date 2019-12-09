How to add SonarQube to CI process
##############################################
:date: 2019-11-26 17:56
:author: Dzmitry Rudnouski

**SonarQube** - is a tool for static code analysis. General concept you may get from this short `wiki article <https://en.wikipedia.org/wiki/SonarQube>`_.
In addition to it I'll tell bit more about SonarQube versions and plugins.

As a standalone app SonarQube is available as free community version and 3 paid
`versions <https://www.sonarsource.com/plans-and-pricing/>`_ - developer,
enterprise и data center. In addition, there is a paid SaaS solution - `sonarcloud.io <https://sonarcloud.io/>`_, which is free however for public projects.
So if you own open source project on GitHub, Bitbucket or Azure DevOps I would recommend to take this opportunity (and I can publish setup instructions).
By the way, here is live example: code of the site you are reading now is analyzed in sonarcloud.io -
`lean-delivery.github.io-src <https://sonarcloud.io/dashboard?id=lean-delivery_lean-delivery.github.io-src>`_.

Out of the box SonarQube provides near 20 plugins, almost all of them are language plugins, their count may vary among the versions. Also there are near 60 third-party plugins of different types:

-  language - e.g. groovy, yaml
-  external analyzers - e.g. checkstyle, findbugs, pmd, ansible lint
-  integration - e.g. Gitlab and Bitbucket authentication
-  code coverage
-  localization and other

It worth saying that free community version differs by capabilities from free sonarcloud.io. Here is comparison:

.. image:: {filename}/images/sonarqube_table1.png

Further in this article I'll tell about free community version.
Current versions now are 7.9.1 LTS и 8.0.

**Installation.**

There are several ways to install SonarQube.

1. Manually. Just don't waste your time.

2. Get official docker `image <https://hub.docker.com/_/sonarqube>`_ at
   dockerhub. I don't use this way, but if you are interested I can compare it with the next one.

3. Install with our `ansible-sonarqube <https://github.com/lean-delivery/ansible-role-sonarqube>`_ role.

Let me tell more about last approach. Look through the readme, get playbook example and adjust it to your needs. Playbook installs SonarQube with the all requirements: java (using our
`ansible-java <https://github.com/lean-delivery/ansible-role-java>`_ role), postgresql database and nginx (for https).

Speaking of the mentioned java role. You may use it not only for SonarQube installation, but in lot of other cases. It's the best role of LDI project and the best java role on Ansible Galaxy.
Pay your attention on amount of supported JDK/JRE types and amount of supported platforms.

To install SonarQube you need instance with at least 4 Gb memory – e.g. t3a.medium в AWS.

Note that besides installation role is able to do some configuration:

-  database migration – required when you've got an installed SonarQube and is going to update it to new version
-  add Jenkins webhook (see below in the article)
-  import custom quality profiles (see below also)
-  configure LDAP authentication

**Configuration.**

First thing you need to do – change default password for admin user in **Administration > Security > Users**. And here what happens when you forget it - `UK cell giant EE left a critical code system
exposed with a default
password. <https://www.zdnet.com/article/mobile-giant-left-code-system-online-default-password/>`_
By the way we are going to add to role ability to change default password.

In addition to password change add token for admin user, you need it later.

Now outsiders are not able to login with default admin/admin, but still able to view your code without login.
So next step is closing guest access in **Administration > Configuration > Security > Force user
authentication.** This feature will be also added to role.

If access to SonarQube is required not only for you but for other team members also, it makes sense to configure LDAP authentication (this option exists in the role) or authentication
via GitHub, Bitbucket, Gitlab, etc.

Let's move on to setting up **Quality Profiles**.
Every language plugin provides built-in quality profile – it's just a set of active and inactive rules, according to which your code is verified.
Except the rules profile may contain templates and you can use them to create your own rules.
Here is example – built-in `profile <https://sonarcloud.io/organizations/lean-delivery/rules?activation=true&qprofile=AW0kegFj4oPgLAsgGJ2v>`_ of python language
(here and below to illustrate something I will give links to SonarCloud, but in SonarQube it looks absolutely the same). 

If you've got custom profiles – you may import them on installation step using our role and then manually set them as default.
If no – just leave as is and built-in profiles will be used by default. Most likely later you will anyway have to create custom profiles from built-in profiles when there will be a need
to activate/inactivate rules or change their settings.

Here I need to tell more about Java profiles, because there are 4 actual Java plugins:

-  out of the box sonar-java-plugin with Sonar way profile, which is used by default
-  third-party sonar-findbugs-plugin with 4 profiles
-  third-party sonar-checkstyle-plugin without profiles
-  third-party sonar-pmd-plugin without profiles

So if you install all 4 plugins and leave Quality Profiles settings as is, then Sonar way profile only will be used for java code verification, in other words you will use out of the box
plugin only and 3 third-party plugins will stay unused. To use for verification all 4 plugins I usually create custom profile, which includes rules from all 4 plugins.
We are planning to add this custom java profile to the role.

One more important note about custom profiles. When you update a plugin and there are new active rules included into update, make sure new rules are activated in custom profile also, 
otherwise there will be no effect from the update. You may do it this way - just after plugin update go to Rules, select Available Since filter and set current date.
Then in Quality Profile filter select one after another built-in and custom profiles. Number of new active rules should be the same. It there are no new rules in custom profile -
activate them manually.

Next step is **Quality Gates** setup. It's a metrics set, according to which code verification is treated as successful or failed.
`Default quality gates <https://sonarcloud.io/organizations/lean-delivery/quality_gates/show/9>`_ code coverage percentage,
duplication percentage, and alos Maintanability, Reliability, Security ratings. I usually use more simple `custom set <https://sonarcloud.io/organizations/lean-delivery/quality_gates/show/7770>`_,
firstly because not all projects have the code coverage, not all teams have capacity to fix non-critical issues, that's why ratings are not required and it's enough not to pass blockers,
criticals (and sometimes majors). We are planning to add custom quality gates import to the role.

Next you need to do is to bind SonarQube to your CI tool. In this article I'm going to use Jenkins. Firstly go to **Administration > Configuration > Webhooks** and add Jenkins webhook
(it can be done by role). Secondly in Jenkins you need to install SonarQube Scanner plugin, then add SonarQube Server in **Manage Jenkins > Configure System** and set:

- name (any, will be used later in pipeline)
- SonarQube url
- token you've added for admin user

An important note about the url. 2 variants are possible if you use https. If you've got a valid certificate you need to preliminarily set it in SonarQube playbook
(self-signed is used by default). And if there is no valid certificate and you use self-signed – you need to import it to Java used by Jenkins.

By the way, for Jenkins installation I would recommend our `ansible-jenkins <https://github.com/lean-delivery/ansible-role-jenkins>`_ role, which may also install mentioned plugin 
and add SonarQube Server in the settings. In our further plans – to publish playbook which can install Jenkins + SonarQube bundle and set certificate correctly.

Sometimes instead of plugin they use separately installed `sonar-scanner <https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/>`_ and set scan parameters in sonar-project.properties file.
In my opinion it's more convenient to use plugin and set scan parameters directly in pipeline.

**Pipeline.**

Let's see the case when you've got a repo with a code and use simple git flow: there is main branch (develop/master), developers add new code in feature branches and open pull requests to main branch.
You plan is to use SonarQube for verification of main branch and pull requests should be also verified.
Here I need to say that free comminuty SonarQube lacks one important feature, that is available in paid versions and in SonarCloud – analysis of branches and pull requests in the same project.
In other words in paid versions and in SonarCloud one repo generates one project which contains info about all verified branches and pull requests. Here is example:

.. image:: {filename}/images/sonarqube_project.png

In free version one repo generates a lot of projects, because you have to create separate project for main branch and for every pull request. It's not so convenient, firstly because new
pull requests are constantly coming and later or sooner you have to think about auto deletion of old projects. Secondly if you've got not one repo there will be a mess.
I'm glad to tell you that there is more convenient way to organize pull requests verification with use of special plugins, but it works for SonarQube 7.6 and below and not for all
repositories:

- for Github – doesn't work, `sonar-github-plugin <https://github.com/SonarSource/sonar-github>`_ is no more supported started from SonarQube 7.2. Most likely it should work with 7.1, but it's quite old now so you will not be able to install latest versions of language plugins.
- for Bitbucket Server – works with use of `sonar-stash-plugin <https://github.com/AmadeusITGroup/sonar-stash/>`_
- for Bitbucket Cloud – works with use of `sonar-bitbucket-plugin <https://github.com/mibexsoftware/sonar-bitbucket-plugin>`_
- for Gitlab – works with use of `sonar-gitlab-plugin <https://github.com/mibexsoftware/sonar-bitbucket-plugin>`_
- for Azure DevOps – doesn't work, there is no plugin

The idea is to create projects for pull request at all, but show info about all found issues in the pull request directly. See how it looks like:

.. image:: {filename}/images/sonarqube_pullrequest.png

This is super convenient, because you may see comment with error message under every bad line of code. Also there is link to SonarQube rule where you may find info about the fix.

Compare this approach by convenience with first one, where project is created for every pull request (like `here <https://github.com/epam/aws-syndicate/pull/51>`_), and to see
the error details developer has to do some clicks to open the project in SonarQube (in example above click View Details > SonarCloud Code Analysis Details > 6 Code Smells, 
then click on one of the issues to see what line of code it's related to).

Let's say you've decided to use 2nd approach - there will be one project in SonarQube for main branch and pull requests will be checked without project creation. Here you may find
`pipeline <https://github.com/lean-delivery/ansible-role-sonarqube/blob/master/files/example_pipeline.groovy>`_ to run these checks.

**How to start using on your project.**

At first add SonarQube analysis step to main branch build, but make it never failed by removing all metrics from Quality Gates.

Project with main branch analysis result should appear in SonarQube. Very ofter you may find here thousands or tens of thousands of issues and it's impossible for developers to review all of them.
This is especially true for huge repositories of monolithic applications. In that case try to switch off rules, that generate issues for almost every file in the repo, or try to change 
their threshold if it's available. To see what rules generate the most issues go to issues list in the project and open Rule filter.

For example you've got 1000 source files in your repo and SonarQube shows "line too long, more than 80 chars" issue for every one of them. It's unlikely that anyone will ever fix this.
It's better to disable this rule or change its threshold. The idea is to leave unique issues only, those that relate to some repository files, but not to all of them.
Besides that be sure to inform dev team what rules were switched off or changed, perhaps they will want to revert some of them.

After that ask dev team to review found blockers and switch off rules for those of them which are not going to be fixed, then to fix all the rest. Also ask to review blocker rules switched off
by default, perhaps developers will want to switch on some of them. Come to agreement that blockers are no more allowed in main branch. To do this add 'Blocker issues is greater than 0' condition
to Quality Gates. Now if there is a blocker in main branch then build will be failed. If blocker is found in pull request its verification will be failed as well. If possible it makes sense
to block merge button in case of failed check.

When blockers are covered you may run the same iteration for criticals, majors and so on. Then you may propose to dev team to keep code coverage level at a certain level, it could be done
by adding appropriate condition to Quality Gates.

When new active and inactive rules appear after plugins update don't forget to ask dev team for review, maybe they will want to switch on/off some of the rules.

In the pipeline you might notice a COMMENT_SEVERITY parameter, it sets minimal severity of issues to be supplied with inline comment (e.g. critical+ or major+). If you've got a lot
of issues in main branch I would not recommend to set this parameter into MINOR or INFO, otherwise you will face the situation, when there are hundred of minor issues comments in every
pull request. If you are on blockers iteration, set this parameter for example to CRITICAL. It means that blockers are commented and not allowed, while the criticals are still allowed but
commented anyway. 

One more advice, check with SonarQube not only dev team code (backend and frontend), but devops code also - use python, groovy, ansible, shellcheck plugins for this purpose.

**What is missed in the article**

How to add code coverage statistics to SonarQube. OWASP plugin. How to link SonarQube to other CI: Bamboo, Azure DevOps. How to verify maven, gradle and other projects with SonarQube. 
How to quickly resolve SonarQube issues by Sergey Podolitsky approach. Read about all of this in the next part on lean-delivery.com only.
