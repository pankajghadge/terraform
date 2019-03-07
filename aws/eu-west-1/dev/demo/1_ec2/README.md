- First create a public and private key with following syntax on any linux OS

	$ ssh-keygen -t rsa -f demo1-key
	Generating public/private rsa key pair.
	Enter passphrase (empty for no passphrase):
	Enter same passphrase again:
	Your identification has been saved in demo1-key.
	Your public key has been saved in demo1-key.pub.
	The key fingerprint is:
	SHA256:mKopotjEgCK0JsDjAfJJfbtHh2Ml/tnkcd+pkLsh3ew
	The key's randomart image is:
	+---[RSA 2048]----+
	|o ..             |
	|+o .. . . .      |
	|.=o  . o +       |
	|= +   .o* . o .  |
	|*+    o+S+ =.o .o|
	|=o   .. . +o=  .o|
	|  o .  . . ooo.  |
	|+o o      ..o.   |
	|=.+        ..E   |
	+----[SHA256]-----+
	 
- Create Key pair
- Create simple ec2 instance with Key pair we have created
