Parameterize our configuration using variables

Variable types:
 Strings : String syntax. Can also be Booleans: true or false.
 Maps	 : An associative array or hash-style syntax. Common functions used with map are lookup, length, merge
 Lists   : An array syntax. Common functions used with List are element, length, sort, concat, index, distinct, contains, join

1. Create file variables.tf and add all variables and their values that we are going to use
2. Use of lookup function for choosing ami depending on the region
3. Use of file function for ec2 instance userdata
4. Create Elastic IP and attach it to instance
5. Create security group and attach it to instance
