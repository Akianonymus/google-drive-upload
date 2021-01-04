# Service account guide

This is guide for explaining how to upload using service accounts in your own drive.

Normal uploading has already been explained in main readme.

Basically, the syntax is `gupload -sa sa.json filename`

Now, this will surely upload successfully but you may notice you don't have access to it.

That's because service accounts are bot accounts, but still a account having seperate storage.

So, to access those files, there are two ways:

1. Share the files using --share option ( with or without email ). This will atleast let you have access.

2. Now, what if we want to have write access and also upload in our own drive ? Well, the answer is to use --rootdir option.

For this to work, there are some steps to be done.

-  Open sa.json file, client_email should be there, copy the corresponding value of it.

-  Make a folder on your own drive.

-  Now using the drive web-ui or drive app-ui, share that specific folder to the email grabbed from the sa.json file.

Now, just upload with the --rootdir option.

```
gupload -sa sa.json --rootdir 'folder id'
```

The files will be uploaded to that specific folder.

Note: Although the files are uploaded in the given rootdir folder, the owner of the file will be the bot service account.
