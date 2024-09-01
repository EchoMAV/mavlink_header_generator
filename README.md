## MAVLink header generator

to use, clone this repo then run
```
./generate_mavlink.sh
```
This will clone EchoMAV's pymavlink repo, along with current message definitions from https://github.com/ArduPilot/mavlink.git. The common message definitions will be copied to the working directory and then all the headers will be build and placed in the build directory.

Note that this repo servers as the master copy for mavnet.xml messages.
