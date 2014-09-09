Git useful stuff
================

Here are some customizations, scripts and other stuff which I use with Git. OS Windows.


Universal fetch
---------------

Being launched from a Git repo directory, script performs fetch from remote no matter it is Git or SVN repo. Save the scrit as `gitfetch.bat` and place it to `%Git%\bin` to get access to it from any directory (assuming the `%Git%\bin` is in your PATH).

```batch
:: Universal (Git/SVN) fetch command
@echo off

IF NOT EXIST %CD%\.git (
	echo "%CD%" is not a Git repo!
	goto :EOF
)

IF NOT EXIST %CD%\.git\svn (
	echo Pulling from git repo...
	git pull
) ELSE (
	echo Fetching from SVN repo...
	git svn fetch
)
```

And the call will look like `D:\Coding\Repo>gitfetch`


BFG tool — removing files from repo history
-------------------------------------------

[BFG](http://rtyley.github.io/bfg-repo-cleaner) is very handy tool that simplifies cleaning of a Git repo history. I use it to get rid of the files that were added to repo but became useless later. The following script helps you to call BFG easily. Save the script as `bfg.bat` and place it to `%Git%\bin` (if this dir is in your PATH).

```batch
@setlocal
@SET CDir=%~dp0%
@java -jar "%CDir%\bfg.jar" %*
```

And the call will look like `D:\Coding\Repo>bfg -D "*.res"`