@echo off

if "%~2"=="" (
    goto usage

)


if not "%~3"=="" (

    goto usage

)





ffmpeg.exe -i %1 -vf "split[a][b]; [a]pad=iw:ih*2[src]; [b]format=rgba,alphaextract[filt]; [src][filt]overlay=0:h" %2



goto :eof

:usage

echo "Usage: convert.bat <input video> <output video>"

goto :eof
