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