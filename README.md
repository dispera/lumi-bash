# lumi-bash
Bash scripts to launch and bootstrap AWS instances with Salt,
Flask, GUnicorn, Nginx and start your Web App!

The Web App and SaltStack formulas are on repository lumi-saltstack

The whole idea is that you can launch EC2 instances, and then
bootstrap the instance with saltstack (install salt, configure
the minion, connect to master, call the desired states and start
a webapp served with nginx.

After the launch instance phase, we get their public IPs
as output so we can connect to the webapp page right then!!

Requirements:
You need to have AWS CLI installed and configured for the desired
AWS account.

Authentication:
For authentication, we use a private key associated to the instances
at the moment of creation (here called diego-key), which needs to be
on the same directory as this script.

Example:
    ./ec2.sh blogapp dev 2 t1.micro

    What this will do is:
    a) Launch 2 instances of type/size t1.micro
    b) It will tell salt to use the dev states, so when we call
    state.highstate, it will use the top.sls file on /srv/salt/dev.
    c) We will use the <app> variable, in this case 'blogapp', to
    know which state to apply - thus, which app we want to serve.
