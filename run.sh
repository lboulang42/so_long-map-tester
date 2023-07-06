#!/bin/bash

# set color codes for green and red
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # no color
CYAN='\033[0;36m'
FILENAME=so_long
# navigate to project directory
cd ..

# compile Makefile
make re

# navigate to maps directory
cd maps

# loop over all subdirectories
for subdir in */; do
    # loop over all files in subdirectory
    for file in "$subdir"*.ber; do
        # navigate back to so_long_tester directory
        cd ../so_long_tester
        # print the name of the file being processed in green
        echo -e "${GREEN}Testing ${FILENAME} on ../maps/$file...${NC}"
        # launch so_long with valgrind and print summary
        so_long_return=$(../${FILENAME} "../maps/$file")
        echo -e "${CYAN}${so_long_return}${NC}"
        valgrind_output=$(valgrind --leak-check=full --show-leak-kinds=all ../${FILENAME} "../maps/$file" 2>&1)
        echo -n "$file "
        if echo "$valgrind_output" | grep -q "ERROR SUMMARY: 0 errors from 0 contexts"; then
            echo -e "${GREEN}[PASS]${NC}"
        else
            echo -e "${RED}[FAIL]${NC}"
        fi
        heap_summary=$(echo "$valgrind_output\n" | awk '/HEAP SUMMARY/ {print; getline; print; getline; print}')
        error_summary=$(echo "$valgrind_output\n" | awk '/ERROR SUMMARY/ {print}')
        echo -e "\033[0;33m$heap_summary\n$error_summary\033[0m"
        # navigate back to maps directory
        cd ../maps
    done
done
