#!/bin/bash

# Exit on failure
set -e
SUDO=$(test ${EUID} -ne 0 && which sudo)

MAVLINK_REPO="https://github.com/ArduPilot/mavlink.git" 
PYMAVLINK_REPO="https://github.com/EchoMAV/pymavlink.git"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Clone / update MAVLINK and PYMAVLINK
mkdir -p ${DIR}/repos
pushd ${DIR}/repos
git clone ${MAVLINK_REPO} mavlink 2> /dev/null || (cd mavlink ; git pull)
git clone ${PYMAVLINK_REPO} pymavlink 2> /dev/null || (cd pymavlink ; git pull)
popd

echo "Copying new definition files..."
$SUDO cp repos/mavlink/message_definitions/v1.0/*.xml ${DIR}/.
PYTHON=python3
MAVGEN=${DIR}/repos/pymavlink/tools/mavgen.py
MESSAGE_FILE=${DIR}/${1:-mavnet.xml}
base=${MESSAGE_FILE##*/}
DIALECT=${base%.*}
WIRE_PROTOCOL=${2:-2.0}

echo 
echo "Generating C"
OUTDIR=${DIR}/build/c
mkdir -p ${OUTDIR}
${PYTHON} ${MAVGEN} -o ${OUTDIR}/${DIALECT} --lang C --wire-protocol ${WIRE_PROTOCOL} ${MESSAGE_FILE}
# generates build/c/${DIALECT}/protocol.h and supporting files

if [ "${WIRE_PROTOCOL}" = "2.0" ] ; then
    # ValueError: C++ implementation only support --wire-protocol=2.0
    echo 
    echo "Generating CPP"
    OUTDIR=${DIR}/build/cpp
    mkdir -p ${OUTDIR}
    ${PYTHON} ${MAVGEN} -o ${OUTDIR}/${DIALECT} --lang C++11 --wire-protocol ${WIRE_PROTOCOL} ${MESSAGE_FILE}
    # generates build/cpp/${DIALECT}/protocol.h and supporting files
fi

echo 
echo "Generating C#"
OUTDIR=${DIR}/build/csharp
mkdir -p ${OUTDIR}
${PYTHON} ${MAVGEN} -o ${OUTDIR}/${DIALECT} --lang CS2 --wire-protocol ${WIRE_PROTOCOL} ${MESSAGE_FILE}
# generates build/csharp/${DIALECT}.cs
mv ${DIR}/build/csharp/${DIALECT}.cs ${DIR}/build/csharp/mavlink.cs

echo
echo "Generating TypeScript"
OUTDIR=${DIR}/build/typescript
mkdir -p ${OUTDIR}
${PYTHON} ${MAVGEN} -o ${OUTDIR}/${DIALECT} --lang TypeScript2 --wire-protocol ${WIRE_PROTOCOL} ${MESSAGE_FILE}
# generates build/typescript/${DIALECT}.ts
mv ${DIR}/build/typescript/${DIALECT}.ts ${DIR}/build/typescript/mavlink.ts

echo
echo "Generating Java"
OUTDIR=${DIR}/build/java
mkdir -p ${OUTDIR}
${PYTHON} ${MAVGEN} -o ${OUTDIR}/${DIALECT} --lang Java2 --wire-protocol ${WIRE_PROTOCOL} ${MESSAGE_FILE}
# generates build/java/${DIALECT}/Parser.java and supportng files

echo
echo "Generating Python"
OUTDIR=${DIR}/build/python
mkdir -p ${OUTDIR}
${PYTHON} ${MAVGEN} -o ${OUTDIR}/${DIALECT} --lang Python --wire-protocol ${WIRE_PROTOCOL} ${MESSAGE_FILE}
# generates build/python/${DIALECT}.py

echo
echo "MAVLink (${DIALECT}) Generated Successfully, results in the build directory"
echo
