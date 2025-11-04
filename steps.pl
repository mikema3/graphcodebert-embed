use strict;
use Steps;




#Add Secrets to GitHub (2 min)
#GitHub repo ? Settings ? Secrets
#Add DOCKERHUB_USERNAME and DOCKERHUB_TOKEN


step("init-repo", "git init");

step("add-files", "git add .");

step("commit1", "git commit -m \"Initial commit: GraphCodeBERT container\"");

step("add-repo", 'git remote add origin git@github-egtrynext:mikema3/graphcodebert-embed.git');
#--set-upstream
step("push1", "git push -u origin main");


step("add-license", "git add LICENSE README.md");
step("commit2", "git commit -m \"Add MIT license and attribution to Microsoft GraphCodeBERT\"");
step("push2", "git push");

usage();
