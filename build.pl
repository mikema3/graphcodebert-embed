use strict;
use Steps;

#build image
step("build", "docker  build -t graphcodebert-embed:local .");

#run, create instance
step("run", "docker run -d --name graphcodebert-embed -p 8000:8000 graphcodebert-embed:local");
#2615a07b8430b385c4c5ea0102f47a2abb18fc7fee5a29d6cacb181b04e951b8

step("status", "docker ps -a | grep graphcodebert-embed");

step("health", "curl http://localhost:8000/health");



usage();
