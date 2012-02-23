#!/bin/bash

rm dmesg.log

adb shell dmesg >> dkmsg.log
