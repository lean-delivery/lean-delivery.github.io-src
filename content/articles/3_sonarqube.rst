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

- for Github – doesn't work, `sonar-github-plugin <https://github.com/SonarSource/sonar-github>`_ is no more supported started from SonarQube 7.2. Most likely it should work with 7.1, 
but it's quite old now so you will not be able to install latest versions of language plugins.
- for Bitbucket Server – works with use of `sonar-stash-plugin <https://github.com/AmadeusITGroup/sonar-stash/>`_
- for Bitbucket Cloud – works with use of `sonar-bitbucket-plugin <https://github.com/mibexsoftware/sonar-bitbucket-plugin>`_
- for Gitlab – works with use of `sonar-gitlab-plugin <https://github.com/mibexsoftware/sonar-bitbucket-plugin>`_
- for Azure DevOps – doesn't work, there is no plugin

The idea is to create projects for pull requests at all, but show info about all found issues directly into pull request. See how it looks like:

.. image:: {filename}/images/sonarqube_pullrequest.png

И это супер удобно, потому что под каждой проблемной строкой появляется комментарий с описанием ошибки и ссылкой на правило в SonarQube, в котором практически всегда указано, как ее исправить.

Сравните этот способ по удобству с первым способом, когда для пулл реквеста создается проект (пример `здесь <https://github.com/epam/aws-syndicate/pull/51>`_), а для того чтобы увидеть в чем суть ошибки разработчику сначала придется сделать несколько кликов, чтобы в этот проект попасть (в примере нажмите View Details > SonarCloud Code Analysis Details > 6 Code Smells, затем кликните на одну из ошибок, чтобы понять к какой строке кода она относится).

Допустим, вы решили использовать второй способ - в SonarQube будет один проект для проверки главной ветки, а пулл реквесты будут проверяться без проекта. Вот здесь можно взять
`пайплайн <https://github.com/lean-delivery/ansible-role-sonarqube/blob/master/files/example_pipeline.groovy>`_ для запуска этих проверок.

**Как начать использовать на проекте.**

Для начала добавьте шаг с SonarQube анализом в сборку основной ветки, но так чтобы он никогда падал – уберите все метрики из Quality Gates.

В SonarQube появится проект с результатом проверки основной ветки. Очень часто вы можете там увидеть, что найдены тысячи или десятки тысяч ошибок и разобрать такое количество разработчикам будет нереально. Особенно это характерно для огромных репозиториев монолитных приложений. В этом случае нужно отключить правила, которые генерируют ошибку чуть ли не на каждый файл репозитория, или изменить порог их срабатывания, если он есть. Чтобы посмотреть, какие правила генерируют больше всего ошибок, в проекте перейдите к списку найденных ошибок и разверните фильтр Rule.

Например, у вас в репозитории 1000 файлов и для каждого из них сгенерировалась ошибка line too long, more than 80 chars. Вряд ли кто-то когда либо будет это исправлять. Лучше отключить такое правило или изменить ему порог срабатывания. Суть в том, чтобы оставить только уникальные ошибки, которые встречаются в некоторых файлах репозитория, но не во всех сразу. При этом обязательно сообщите разработчикам, какие правила вы отключили и какие изменили, возможно они что-то захотят вернуть обратно.

Далее попросите разработчиков посмотреть найденные блокеры, отключить правила для тех из них, которые они не будут исправлять, затем исправить все оставшиеся. Попросите заодно просмотреть
правила-блокеры, которые по умолчанию выключены, возможно разработчики захотят некоторые из них включить. Договоритесь о том, что
блокеры в главную ветку вы больше не пропускаете. Для этого добавьте в Quality Gates метрику Blocker issues is greater than 0. Теперь если в главной ветке появится блокер – сборка билда
упадет. Если блокер вносится пулл реквестом, проверка пулл реквеста тоже упадет. Если есть возможность - стоит заблокировать мерж пулл реквеста при наличии упавшей проверки.

После блокеров точно такую же итерацию можно провести для критикалов, потом мажоров и т.д. Затем можно предложить разработчикам поддерживать процент покрытия кода на определенном уровне путем
добавления в Quality Gates соответсвующей метрики.

Если вы обновляете плагины и появляются новые активные и неактивные правила, не забывайте попросить разработчиков просмотреть их - возможно они захотят какие-то отключить, а какие-то включить.

В пайплайне вы могли заметить такой параметр как COMMENT_SEVERITY, который показывает для каких ошибок SonarQube будет добавлять подстрочный комментарий (например, для всех критикалов
и старше, или для всех мажоров и старше). Если у вас в главной ветке много ошибок, я не рекомендую выставлять этот параметр в MINOR или INFO, иначе вы столкнетесь с ситуацией, когда
в каждом пулл реквесте будет сотня комментариев о минорных ошибках. Если вы в текущей итерации занимаетесь блокерами, то выставляйте этот параметр например равным CRITICAL. Получится, что блокеры вы не пропускаете, а комментарии будут выводится и для блокеров, и для критикалов.

Еще один совет – проверяйте с помощью SonarQube не только код разработчиков (бекенд и фронтенд), но и свой девопс код – плагины python, groovy, ansible, shellcheck вам в этом помогут.

**О чем не рассказано в этой статье.**

О добавлении code coverage статистики в SonarQube. Об OWASP плагине. О привязывании SonarQube к другим CI системам : Bamboo, Azure DevOps. О проверке maven, gradle и других проектов с помощью SonarQube. О радикальном исправлении ошибок по методу Сергея Подолицкого. 
Обо всем этом читайте в следующей части, только на lean-delivery.com.
