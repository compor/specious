#!/usr/bin/env python

import sys
import re
import argparse


def icc_report_parse(input_filename, verbose):
    top_loop_start = '^LOOP BEGIN'
    loop_start = 'LOOP BEGIN'
    top_loop_end = '^LOOP END'
    loop_end = 'LOOP END'
    loop_par = 'LOOP WAS AUTO-PARALLELIZED'

    in_loop = False
    file_details = ''
    source_filename = ''
    loop_line = ''
    loops = {}
    loop_level = -1

    loop_count = 0
    toplevel_loop_count = 0

    with open(input_filename, buffering=1) as input_file:
        for line in input_file:
            if re.search(top_loop_start, line):
                in_loop = True
                parts = line.split()
                file_details = parts[3]

            if re.search(loop_start, line):
                loop_level += 1

            if re.search(top_loop_end, line):
                in_loop = False 

            if re.search(loop_end, line):
                loop_level -= 1

            if in_loop and re.search(loop_par, line):
                path_parts = file_details.split('/')

                file_parts = path_parts[len(path_parts) - 1].split('(')
                source_filename = file_parts[0]
                loop_line = int(file_parts[1].split(',')[0])

                if not source_filename in loops:
                    loops[source_filename] = [ (loop_line, loop_level) ]
                else:
                    loops[source_filename].append((loop_line, loop_level))
        
    for f, v in loops.items():
        for loop in v:
            loop_count += 1

            if loop[1]:
                toplevel_loop_count += 1

            if verbose:
                print '%s %d %d' % (f, loop[0], loop[1])

    print 'total parallel loops: %d' % loop_count
    print 'total top-level parallel loops: %d' % toplevel_loop_count


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Parse Intel ICC reports')

    parser.add_argument('input_filename', type=str, 
                        help='Intel ICC report file name')
    parser.add_argument('--verbose', action='store_true', 
                        help='Intel ICC report file name')

    args = parser.parse_args()
    
    icc_report_parse(args.input_filename, args.verbose)
