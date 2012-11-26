#!/usr/bin/python

import os, sys
import prettyformat
import fileinput

module = sys.argv[1]

line = sys.stdin.readline()
while(line):
    valid=False
    if("libtool:" in line):
        if("libtool: compile:" in line):
            action = "CC"
            description = line.split("-o")[1].strip().split(" ")[0].strip()
            valid = True
        elif("libtool: link:" in line):
            action = "LN"
            splits = line.split("-o")
            if(len(splits) > 1):
                description = splits[1].strip()
                valid = True
            else:
                description = "intermediate step"
                valid = False

        else:
            action = "UKNOWN"
            description = "LIBTOOL STEP"
    else:
        if(line.startswith("rm")):
            action = "RM"
            description = line.strip()
            valid = True
        elif(line.strip().startswith("gcc")):
            action = "CC"
            description = line.strip()
            valid = True
        elif(line.strip().startswith("g++")):
            action =  "CXX"
            description = line.strip()
            valid = True
        elif(line.strip().startswith("checking")):
            action = "CHK"
            description = line.strip()
            valid = True
        else:
            action = "MISC"
            description = line.strip()
            valid = True

    if(valid == True):
        prettyformat.pretty(action, module, description, False)

    line = sys.stdin.readline()
