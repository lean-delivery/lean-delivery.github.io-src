Contribution guide post
#######################
:date: 2019-08-14 13:50
:author: Aliaksei Zeliashchonak
:tags: non-technical
:slug: init

So, if you decided to create an article in LDI blog please follow this guide:

1. Clone source code from https://github.com/lean-delivery/lean-delivery.github.io-src.git
2. Create a new branch.
3. Create a new page in content/articles folder with the next count number of existing pages in the name with “rst” type, for example “1_contribution_guide.rst”
4. Commit changes and push it to github.
5. It will be ran a CD pipeline with rst syntax checker, and if it will be passed successfully, will be placed a comment with a link where you can preview your changes to the current commit.(You could see a build status here https://gitlab.com/lean-delivery/lean-delivery-github-io-src/-/jobs/)

If you want to publish your changes in lean-delivery.com just create a merge request from your branch to master.

Thank you for your contribution!

Best regards,
Lean-delivery Team.
