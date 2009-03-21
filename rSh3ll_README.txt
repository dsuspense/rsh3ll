rSh3ll (Amazon S3 command shell for Ruby)
-----------------------------------------

The rSh3ll is a Ruby based command shell for managing your Amazon S3 objects.
It is built upon the Amazon S3 REST Ruby library (S3.rb) and has no external dependencies.
rSh3ll uses the built-in openssl ruby library (no more dependency on the hmac-sha1 ruby library). 

Preparing rSh3ll
----------------

Edit the rSh3ll.rb and fill in your AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY

Running rSh3ll
--------------

To run rSh3ll you can either:
1. Run 'ruby rSh3ll.rb'
2. Run the rSh3ll.bat file.

Using rSh3ll
------------

Once you have rSh3ll started, you can type "help" at the prompt to get a quick
reminder of the commands. rSh3ll isn't very helpful when you misuse commands,
it will just tell you tersely what it expects. Most usage errors will be
signaled by a terse error message, but a few will result in
IllegalArgumentException stack traces being printed to the screen.

* bucket [bucketname]

Changes the current bucket, or displays the current bucket if one is set. The
current bucket need not exist, in fact, the only way to create one is to change
the current bucket and then use "createbucket".

* count [prefix]

Counts the number of items in the current bucket. If your bucket contains a lot
of items, this could take a long time to run since the only way of counting the
items is to list them all. If the prefix is specified, only count the items in
the bucket that have this prefix in the ID.

* createbucket

Creates the current bucket.

* createbucket ['private'|'public-read'|'public-read-write'|'authenticated-read']

Creates the current with the ACL specified.

* delete <id>

Deletes an item from the current bucket.

* deleteall [prefix]

Deletes all the items from the current bucket. Be careful with this one, it
won't ask you to make sure you're sure. By specifying a prefix, you can limit
the deletion to only items that have this prefix in their ID. This command
could take a while to run if your bucket has a lot of items. For one way to
speed it up, see the "threads" command.

* deletebucket

Deletes the current bucket.

* get <id>

Gets the item with the given ID and displays it to the terminal.

* getacl ['bucket'|'item'] <id>

Gets the ACL for a bucket or item with the given ID.

* getfile <id> <file>

Gets the item with the given ID and stores it in the specified file.

* getfilez <id> <file>

Gets the ZLIB compressed item with the given ID and stores it in the specified file.

* gettorrent <id> <file>

Gets the BitTorrent file (.torrent) of the given ID and stores it.

* head ['bucket'|'item'] <id>

Gets the head information for a bucket or item identified by <id>.
Use this to retrieve information about a specific object, without actually fetching the object itself. 
This is useful if you're only interested in the object metadata, and don't want to waste bandwidth on the object data.

* host [hostname]

Sets the S3 host to the given hostname, or displays the current host if no argument is given.

* list [prefix] [max]

List the items in the current bucket, subject to the given constraints. 
If prefix is specified, the listing is limited to the given prefix.
You may use the wildcard '*' or no prefix to list ALL ITEMS). 
If max is specified, the number of returned results will be limited
to max items. 
The S3 server may impose its own limits on the number of items returned.

* listatom [prefix] [max]

List the items in the current bucket as a valid Atom 1.0 feed, subject to the given constraints. 
If prefix is specified, the listing is limited to the given prefix.
You may use the wildcard '*' or no prefix to list ALL ITEMS). 
If max is specified, the number of returned results will be limited
to max items. 
The S3 server may impose its own limits on the number of items returned.

* listrss [prefix] [max]

List the items in the current bucket as a valid RSS 2.0 feed, subject to the given constraints. 
If prefix is specified, the listing is limited to the given prefix.
You may use the wildcard '*' or no prefix to list ALL ITEMS). 
If max is specified, the number of returned results will be limited
to max items. 
The S3 server may impose its own limits on the number of items returned.

* listbuckets

Lists all the buckets belonging to the Access Key ID currently in use.

* pass [password]

Sets the Secret Access Key used to authenticate with S3.

* put <id> <data>

Stores the given data into S3 with the given ID. The data is limited to a
single line. See putfile for a way to put more data.

* putfile <id> <file>

Stores the contents of the given file into S3 under the specified ID.

* putfilewacl <id> <file> ['private'|'public-read'|'public-read-write'|'authenticated-read']

Stores the contents of the given file into S3 under the specified ID, with the specified ACL.

* setacl ['bucket'|'item'] <id> ['private'|'public-read'|'public-read-write'|'authenticated-read']

Sets the ACL for a bucket or item of the specified ID.

* user [username]

Sets the Access Key ID used to authenticate with S3.


Amazon Digital Services disclosure
----------------------------------

This software code is made available "AS IS" without warranties of any
kind.  You may copy, display, modify and redistribute the software
code either by itself or as incorporated into your code; provided that
you do not remove any proprietary notices.  Your use of this software
code is at your own risk and you waive any claim against Amazon
Digital Services, Inc. or its affiliates with respect to your use of
this software code. (c) 2006 Amazon Digital Services, Inc. or its
affiliates.

SilvaSoft, Inc disclosure
-------------------------
This software makes use source code provides by Amazon Digital Services, Inc.
Specifically, the Amazon S3 REST API for Java and the S3 Shell source code.
All modified source code (c) 2006 SilvaSoft, Inc.

For questions, bug reports or suggestions see contact info below.

Contact Info
------------
Email: dominic@silvasoftinc.com
Web: http://www.silvasoftinc.com
Blog: http://jroller.com/page/silvasoftinc
