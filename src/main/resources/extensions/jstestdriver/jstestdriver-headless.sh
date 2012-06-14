#!/bin/bash
# directory to write output XML (if this doesn't exist, the results will not be generated!)
JSTD_JAR="$1"
OUTPUT_DIR="$2"
JSTD_PORT="$3"
JSTD_BROWSER="$4"
JSTD_CONFIG="$5"

XVFB=`which Xvfb`
if [ "$?" -eq 1 ];
then
    echo "Xvfb not found."
    exit 1
fi

$XVFB :99 -ac &    # launch virtual framebuffer into the background
PID_XVFB="$!"      # take the process ID
export DISPLAY=:99 # set display to use that of the xvfb

# run the tests
java -jar "${JSTD_JAR}" --config "${JSTD_CONFIG}" --port "${JSTD_PORT}" --browser "${JSTD_BROWSER}" --tests all --testOutput "${OUTPUT_DIR}" --runnerMode DEBUG

kill $PID_XVFB     # shut down xvfb (firefox will shut down cleanly by JsTestDriver)
echo "Done."