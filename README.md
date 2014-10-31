stelligent-demo-project
=======================

This is a demonstration mini project for Stelligent

Prerequisites
-------------

You must have the AWS CLI utility installed and available
in your system path. Please see http://aws.amazon.com/cli/

Usage
-----
    
    curl http://stelligent-demo.losergeek.org/

Note that the connection should time out

    env AWS_ACCESS_KEY=foo AWS_SECRET_ACCESS_KEY=bar ./cfscript.sh -f

    sleep 120

Start the CloudFormation provision and wait about 2 minutes

    curl http://stelligent-demo.losergeek.org/

    <html><head><title>Hello, Stelligent</title></head><body><h1>Hello, Stelligent!</h1></body></html>

Explanation
-----------

The cfscript.sh script uses the stelligent.cf CloudFormation script
along with the parameters/jeffb/params.json parameter file
to launch a CF stack on my (Jeff Bachtel's) AWS account.

The shell script is a simplified version of a utility I created
for a more complex project where multiple CF stacks needed to
be provisioned simultaneously, with the JSON parameter file
varying (some stacks using parameter file A, some using B).

The CloudFormation script provisions an Amazon Linux t1.micro
instance with httpd (Apache) installed. In addition, it specifies
that tcp 22 (ssh), 80 (http) and 443 (https) should be allowed
incoming in the instance security group.

The CloudFormation script uses the ability to define the contents
of a file to handle the "Hello, Stelligent" portion of the project,
by writing to /var/www/html/index.html

Ramblings
---------

You don't, of course, use JUST CloudFormation to do anything
complicated. It tries really hard, but is best for ensuring files
are injected into your instance securely, and then a proper SCM
is kicked off. For this demonstration case, the addition of a
SCM was a bit overmuch.

This script requires AWS creds be passed on the command line.
Previously, I hardcoded profile names, and users were expect to
create ~/.aws/config files with credentials linked to their IAM
accounts.

Defining a custom policy for this for the stelligent-demo user
I created in IAM was a huge pain. A large part of this pain
is due to the CF stack determining whether an EC2 instance has
completed provisioning. This requires a certain action
(somewhere in ec2:Describe\* ) that fails silently,
never registering the EC2 instance as created.
