@echo off
SETLOCAL EnableDelayedExpansion
CLS

IF "%1"=="/?" GOTO HELP
IF "%1"=="" (SET WIDTHCOUNT=5) ELSE (SET WIDTHCOUNT=%1)
IF "%2"=="" (SET HEIGHTCOUNT=%WIDTHCOUNT%) ELSE (SET HEIGHTCOUNT=%2)

:: 
SET /A WIDTH=%WIDTHCOUNT% - 1
SET /A HEIGHT=%HEIGHTCOUNT% - 1

::Generate an empty maze, set each cell to zero
FOR /L %%h IN (0, 1, %HEIGHT%) DO (
		FOR /L %%w IN (0, 1, %WIDTH%) DO (
			SET M[%%h][%%w]=0
		)	
)

::Start the process
CALL :DISPLAY
SET /A COUNT=0
CALL :CARVE 0 0
::CALL :DISPLAY
SET M
GOTO EOF

:CARVE
::SETLOCAL
SET CX=%1
SET CY=%2
CALL :DIRECTIONS
SET /A COUNT=!COUNT!+1
ECHO !COUNT! %DIRECTIONS%
FOR %%D IN (%DIRECTIONS%) DO (
	ECHO !COUNT! %%D
	REM pause

	CALL :DX %%D
	SET /A NX=!CX! + !DX!
	
	CALL :DY %%D
	SET /A NY=!CY! + !DY!
	
	IF !NY! GEQ 0 IF !NY! LEQ %WIDTH% IF !NX! GEQ 0 IF !NX! LEQ %HEIGHT% (
		
		SET /A NCELL=M[!NY!][!NX!]
		IF !NCELL!==0 (

			CALL :CONVERT %%D
			CALL :OPPCONVERT %%D

			SET /A M[!CY!][!CX!]^|=!CONVERT!
			SET /A M[!NY!][!NX!]^|=!OPPCONVERT!
			
			CALL :DISPLAY
			CALL :CARVE !NX! !NY!	
		)
	)
)
GOTO EOF

:DX
IF %1==E (SET DX=1)
IF %1==W (SET DX=-1)
IF %1==N (SET DX=0)
IF %1==S (SET DX=0)
GOTO EOF

:DY
IF %1==E (SET DY=0)
IF %1==W (SET DY=0)
IF %1==N (SET DY=-1)
IF %1==S (SET DY=1)
GOTO EOF

:CONVERT
IF %1==N (SET CONVERT=1)
IF %1==S (SET CONVERT=2)
IF %1==E (SET CONVERT=4)
IF %1==W (SET CONVERT=8)
GOTO EOF

:OPPCONVERT
IF %1==N (SET OPPCONVERT=2)
IF %1==S (SET OPPCONVERT=1)
IF %1==E (SET OPPCONVERT=8)
IF %1==W (SET OPPCONVERT=4)
GOTO EOF

:DIRECTIONS
SET /A DIRECTIONS=%RANDOM% * 24 / 32768 + 1
IF %DIRECTIONS%==1  (SET DIRECTIONS=N S E W) & GOTO EOF
IF %DIRECTIONS%==2  (SET DIRECTIONS=N S W E) & GOTO EOF
IF %DIRECTIONS%==3  (SET DIRECTIONS=N E S W) & GOTO EOF
IF %DIRECTIONS%==4  (SET DIRECTIONS=N E W S) & GOTO EOF
IF %DIRECTIONS%==5  (SET DIRECTIONS=N W S E) & GOTO EOF
IF %DIRECTIONS%==6  (SET DIRECTIONS=N W E S) & GOTO EOF
IF %DIRECTIONS%==7  (SET DIRECTIONS=S N E W) & GOTO EOF
IF %DIRECTIONS%==8  (SET DIRECTIONS=S N W E) & GOTO EOF
IF %DIRECTIONS%==9  (SET DIRECTIONS=S E N W) & GOTO EOF
IF %DIRECTIONS%==10 (SET DIRECTIONS=S E W N) & GOTO EOF
IF %DIRECTIONS%==11 (SET DIRECTIONS=S W N E) & GOTO EOF
IF %DIRECTIONS%==12 (SET DIRECTIONS=S W E N) & GOTO EOF
IF %DIRECTIONS%==13 (SET DIRECTIONS=E N S W) & GOTO EOF
IF %DIRECTIONS%==14 (SET DIRECTIONS=E N W S) & GOTO EOF
IF %DIRECTIONS%==15 (SET DIRECTIONS=E S N W) & GOTO EOF
IF %DIRECTIONS%==16 (SET DIRECTIONS=E S W N) & GOTO EOF
IF %DIRECTIONS%==17 (SET DIRECTIONS=E W N S) & GOTO EOF
IF %DIRECTIONS%==18 (SET DIRECTIONS=E W S N) & GOTO EOF
IF %DIRECTIONS%==19 (SET DIRECTIONS=W N S E) & GOTO EOF
IF %DIRECTIONS%==20 (SET DIRECTIONS=W N E S) & GOTO EOF
IF %DIRECTIONS%==21 (SET DIRECTIONS=W S N E) & GOTO EOF
IF %DIRECTIONS%==22 (SET DIRECTIONS=W S E N) & GOTO EOF
IF %DIRECTIONS%==23 (SET DIRECTIONS=W E N S) & GOTO EOF
IF %DIRECTIONS%==24 (SET DIRECTIONS=W E S N) & GOTO EOF
GOTO EOF


::Display the maze
:DISPLAY
cls
For /L %%h IN (0, 1, %HEIGHT%) DO (

	::Clear top, build top, display top twice the width minus 2
	SET TOP=
	SET /A WIDTHMINUSTWO=%WIDTHCOUNT% * 2 - 2
	IF %%h EQU 0 (FOR /L %%w IN (0, 1, !WIDTHMINUSTWO!) DO (SET TOP=_!TOP!))
	
	 ::note 2x space after 'ECHO' for display purposes
	IF %%h EQU 0 ECHO  !TOP!
	
	::Clear row, build row, display row
	SET ROW=^|
	FOR /L %%w IN (0, 1, %WIDTH%) DO (
		
		CALL :CONVERT S
		SET /A ISSOUTH=M[%%h][%%w] ^& !CONVERT!
		IF NOT !ISSOUTH!==0 (SET ROW=!ROW! ) 
		IF !ISSOUTH!==0 (SET ROW=!ROW!_) 
		
		CALL :CONVERT E
		SET /A ISEAST=M[%%h][%%w] ^& !CONVERT!
		IF NOT !ISEAST!==0 (
			SET /A ACELL=M[%%h][%%w]
			SET /A BBCELL=%%w + 1 
			SET /A BCELL=M[%%h][!BBCELL!]
			CALL :CONVERT S
			SET /A ISEAST=!ACELL! ^| !BCELL!
			SET /A ISEAST=!ISEAST! ^& !CONVERT!
			IF NOT !ISEAST!==0 (SET ROW=!ROW! ) 
			IF !ISEAST!==0 (SET ROW=!ROW!_)
		) ELSE (SET ROW=!ROW!^|)
	)
	ECHO !ROW!
)
GOTO EOF

:EOF