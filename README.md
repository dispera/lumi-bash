# lumi-bash
![Bash](https://tiswww.case.edu/php/chet/img/bash-logo-web.png "BASH")

Introduction
------------
This is our bash script to launch and bootstrap AWS instances
with Salt, Flask, GUnicorn, Nginx and start your Web App!

The whole idea is that you can launch EC2 instances, and then
bootstrap the instance with saltstack (install salt, configure
the minion, connect to master, call the desired states and start
a webapp served with nginx.

After the launch instance phase, we get their public IPs
as output so we can connect to the webapp page right then!!

Requirements:
-------------
You need to have AWS CLI installed and configured for the desired
AWS account.

Authentication:
---------------
For authentication, we use a private key associated to the instances
at the moment of creation (here called diego-key), which needs to be
on the same directory as this script.

Related Files:
--------------
- The SaltStack formulas are on repository lumi-saltstack.
- The Flask apps are on repository lumi-webapps.

Example:
--------
'''bash
./ec2.sh blogapp dev 2 t1.micro
'''

What this will do is:
* Launch 2 instances of type/size t1.micro
* Tell salt to use the dev states, so when we call
state.highstate, it will use the top.sls file on /srv/salt/dev.
* Use the <app> argument, in this case 'blogapp', to know which
state to apply - thus, which app we want to deploy and serve.
