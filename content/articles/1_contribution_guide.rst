Contribution guide
#######################
:date: 2019-08-14 13:50
:author: Aliaksei Zeliashchonak
:tags: non-technical
:slug: contribution_guide

Hi all!

When you'll decide to share your perfect solution with community by posting it in LDI blog please follow this guide:

1. Clone source code

.. code-block:: bash

   git clone https://github.com/lean-delivery/lean-delivery.github.io-src.git

2. Create a new branch

.. code-block:: bash

   git checkout -b <branch_name>

3. Create a new page in content/articles folder with the next count number of existing pages in the name with "rst" type, for example "1_contribution_guide.rst"

4. Commit changes

.. code-block:: bash

   git commit

5. Push it to github

.. code-block:: bash

   git push

6. It will be ran a CD pipeline with rst syntax checker, and if it will be passed successfully, will be placed a comment with a link where you can preview your changes to the current commit.

You could see a build status here https://gitlab.com/lean-delivery/lean-delivery-github-io-src/-/jobs/

If you want to publish your changes in lean-delivery.com just create a merge request from your branch to master.

You can see the logic of CD in gitlab-ci.yml

Deployment preview steps in any "dev" branches are:

1. Run RST Validation of ".rst" files.
2. Remove files (if exists) in s3 subfolder named as a current branch.
3. Build a static site with "pelican" (https://blog.getpelican.com/)
4. Change the default app URL in pelicanconf.py.
5. Create (if not exists) subfolder in s3 bucket with the name of the current branch.
6. Copy output files after the build to this subfolder.
7. Create a comment with a link to preview page (https://preview.lean-delivery.com/<branch_name>) in the current commit.

Deployment from the master branch:

1. Build a static site with "pelican" (https://blog.getpelican.com/)
2. Copy output files after the build to "docs" folder (it's a GitHub submodule for GitHub Pages)
3. Update submodule with rebase.

.. image:: {filename}/images/contribution_guide.png

Thank you for your contribution!

Best regards,

Lean-delivery Team.
