:: Preparation: unpack minimal FPC compiler (http://www.getlazarus.org/setup/minimal/) to 
:: %FOLDER%\fpc-min\ and run this batch with 1st parameter = %FOLDER%
::   %1 [optional] - base folder with folder fpc-min\ containing minimal compiler 
::     where the new FPC will be built. If omitted, current dir will be used.

@ECHO OFF

SETLOCAL

:: === Presets - you may change them ===

:: SVN tag to download from - adjust to desired version
SET RepoFolder=release_3_0_0
:: Comment these options out to skip cross-build
SET Cross_Win_64=1
SET Cross_Lin_32=1
SET Cross_Lin_64=1

:: === Init ===

IF NOT .%~1.==.. (SET BaseDir=%~1) ELSE (SET BaseDir=%CD%)
SET CDir=%~dp0%
SET MinCompiler=%BaseDir%\fpc-min\bin\i386-win32
SET PATH=%MinCompiler%
SET NewFPCDir=%BaseDir%

:: === Action ===

PUSHD "%NewFPCDir%"

:: Get src
CALL svn co http://svn.freepascal.org/svn/fpc/tags/%RepoFolder% .\ || GOTO :Err

:: Prepare minimal compiler for building and cross compiling apps
COPY "%CDir%\binutils\*.*" "%MinCompiler%\" 1>2 2> nul

:: Main stage - build for Win-x32. Other builds will be done with this compiler.
CALL make all & CALL make install "INSTALL_PREFIX=%NewFPCDir%" || GOTO :Err

:: Prepare compiler for cross compile
SET Compiler=%NewFPCDir%\bin\i386-win32

:: Cross
IF DEFINED Cross_Win_64 (CALL make crossinstall CPU_TARGET=x86_64 OS_TARGET=win64 "INSTALL_PREFIX=%NewFPCDir%" || GOTO :Err)
IF DEFINED Cross_Lin_32 (CALL make crossinstall CPU_TARGET=i386 OS_TARGET=linux "INSTALL_PREFIX=%NewFPCDir%" || GOTO :Err)
IF DEFINED Cross_Lin_64 (CALL make crossinstall CPU_TARGET=x86_64 OS_TARGET=linux "INSTALL_PREFIX=%NewFPCDir%" || GOTO :Err)

:: Init FC config
PUSHD "%Compiler%"
CALL fpcmkcfg -d "basepath=%BaseDir%" -o .\fpc.cfg
CALL fpc -iV
POPD

:: Prepare compiler for building and cross compiling apps
COPY "%CDir%\binutils\*.*" "%Compiler%\" 1>2 2> nul
COPY "%MinCompiler%\gdb.exe" "%Compiler%\" 1>2 2> nul
COPY "%MinCompiler%\make.exe" "%Compiler%\" 1>2 2> nul
COPY "%CDir%\lib" "%NewFPCDir%\" 1>2 2> nul

GOTO :EOF

:Err
POPD
PAUSE