#!/bin/bash

rm last_kmsg.log

adb  shell cat /proc/kmsg >> last_kmsg.log
