Git. Store credentials permanently via helpers
==============================================

One of drawbacks when using Git is that one has to enter password every time he connects to remote server (if that server requires authorization, of course). When you push frequently it becomes annoying.
Luckily there's a way to solve the problem by storing credentials in config files. But beware that your passwords might be accessible to other users of the machine!

Let's do it.
Again,

**Your passwords might be accessible to other users of the machine!**

Step 1
------

Open your preferred Git config file. By preferred I mean the one that you wish to store your login/password in. Git utilizes two config files:
* "System" - the file `{git_dir}\etc\gitconfig`
* "Global" - the file `%HOME%\.gitconfig`

Using the latter is more secure as your home folder normally isn't accessible to other users. Admins may access it anyway so be warned. Also if you follow the simpler way of storing (*Step 2.1.x*) the location of credentials storage file will be fixed to `%HOME%`. I personally prefer portable solutions and I'm the only user of the machine so I selected "System" config file.

Step 2
------

Open config file and decide what your needs are.
If you have one account per remote Git domain, you can use simple way. Proceed to [Steps 2.1.x](#step-211).
If you have more than one account per Git domain (like two accounts on github) you'll need a bit more complicated actions, proceed to [Steps 2.2.x](#step-221).

Step 2.1.1
----------

Add following lines to the end of gitconfig file you've opened:
```
[credential]
	helper = store
```

This will enable credentials storing. Save the file.

Step 2.1.2
----------

Loop through all the local repos connected with remotes and execute push or pull. Input password when you're asked to.
Thats all, your credentials are remembered in %HOME%\.git-credentials and you won't be asked for password again. Check that by executing push/pull one more time.
**Note** that the path of this file seem to be hardcoded; at least I haven't found a way to change it.

Mission complete.

Step 2.2.1
----------

If you have several accounts on some Git domain the above method won't fit because Git would always use only one credentials for all communication with domain. So we need to use custom credential helper. If lots of technical info don't frighten you, you can read theory [here](http://www.kernel.org/pub/software/scm/git/docs/gitcredentials.html) and [here](http://www.kernel.org/pub/software/scm/git/docs/technical/api-credentials.html). But in practice everything's much simpler. The idea is to create a trivial shell script that would do nothing but returning its command line parameter as password in the form git requires.

Add all your remote Git servers to the end of gitconfig file you've opened at [Step 2](#step-2) in the following form:
````
[credential "https://{username1}@{git_server_addr}"]
	helper = repeater {passwd1}
[credential "https://{username2}@{git_server_addr}"]
	helper = repeater {passwd2}
````

Where
* `domain_addr` is the domain with Git server that hosts your remote repos. For example, `https://github.com`.
* `username1` and `passwd1` are your first account on that domain. For example, `Fr0sT-Brutal` and `foo`.
* `username2` and `passwd2` are your second account on that domain.

Of course, use appropriate protocol (git:// or http(s)://) in domain addresses.

By this setting we tell git to use a custom credential helper named `repeater` for every address that starts with `https://{username1}@{domain_addr}` and execute it with password `{passwd1}` as first command-line parameter; for every address that starts with `https://{username2}@{domain_addr}` execute it with password `{passwd2}` and so on.

Save the file and close it.

Step 2.2.2
----------

Proceed to `{git_dir}\bin` directory (*also see note below*)), create text file there, name it `git-credential-repeater` (no extension!) and insert the following lines:

```bash
#! /bin/sh
# Git credential helper, simply returns password transferred in 1st command line parameter.
# Must be registered in git config in the following form:
# [credential "http://{user_name}@{domain_name}"]
# 	helper = repeater {repo_pass}
if [ $2 = "get" ]; then
	echo "password=$1"
fi
```
Save it and close. As you can see, it's our trivial repeater that returns something transferred in 1st parameter (and it will be a password) if command transferred in 2nd parameter is `get`.

**Important note**

Since version 2.x Git (at least Windows build) stopped finding scripts placed in `{git_dir}\bin` and `{git_dir}\cmd`. I had to place it in `{git_dir}\mingw32\libexec\git-core` to get it working.

Step 2.2.3
----------

Change remote repos' URLs where you need authorization to include your user name: `https://YourUserName@github.com/YourUserName/YourRemoteRepo.git`. This can be done via GUI or by editing `{Your_Local_repo_dir}\.git\config` file. If things are correct, this file should contain something like

```
[remote "origin"]
	url = https://Fr0sT-Brutal@github.com/Fr0sT-Brutal/App_EXIFTimeEdit.git
	fetch = +refs/heads/*:refs/remotes/origin/*
```

**This step is important!** Without it, git would be unable to distinguish your accounts and would prompt you for credentials. Note that your username in the URL must be strictly identical (including case) to the one you wrote in gitconfig file.

That's it. Check that you've done everything right by pushing/pullng to/from remotes you entered. Your credentials should be taken from config without prompting you.