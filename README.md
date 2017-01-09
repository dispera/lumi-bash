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

The called salt states will:
----------------------------
* Install flask.
* Configure our flask webapp.py app.
* Install gunicorn.
* Configure the wsgi.py app file which just imports the flask app to gunicorn.
* Add a gunicorn webapp.conf file to init which will run the wsgi app as a
process. We will be able to start and stop it with 'start webapp' and
'stop webapp'.
* Install nginx
* Configure nginx to listen on port 80 and serve on / the web app
running as the gunicorn unix process.

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

Related Repositories:
--------------
- The SaltStack formulas are on repository lumi-saltstack.
- The Flask apps are on repository lumi-webapps.

Output Files:
------------------------------------------------
* aws_run_log (the log of the ec2 instances launch output)
* bootstrap.sh (the script passed as user-data to the aws run-instances)
* instance_id_list (this is the list of instance IDs)
* instance_ip_list (this is the list of instance IPs)

Example:
--------
./ec2.sh blogapp dev 2 t1.micro

What this will do is:
* Launch 2 instances of type/size t1.micro
* Tell salt to use the dev states, so when we call
state.highstate, it will use the top.sls file on /srv/salt/dev.
* Use the <app> argument, in this case 'blogapp', to know which
state to apply - thus, which app we want to deploy and serve.
The other available option is 'helloapp'.
