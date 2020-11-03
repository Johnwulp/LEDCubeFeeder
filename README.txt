# LEDCubeFeeder

[![Open Source Love png1](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

<a href="https://www.buymeacoffee.com/johnwulp" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" style="height: 51px !important;width: 217px !important;" ></a>

## Windows service that sends CPU temperature and load % information via UDP to the ledcube

LED Cube project:
https://github.com/Staacks/there.oughta.be/tree/master/led-cube

## Install:
- Download the release setup file from: https://github.com/Johnwulp/LEDCubeFeeder/releases
- During setup you will be asked to fill in the LEDCube IP address, the UDP port (default 1234) and the update interval (in miliseconds)
- After installation the service will be started, and UDP data will be send to given IP address

## Changing IP, port or interval
There is no UI to do this, you need to change the parameters in 'LEDCubeFeeder.exe.config' manually

## Debugging
If you want to see what this service is sending, open file 'NLog.config' and change 'minlevel="Info"' with 'minlevel="Debug"'