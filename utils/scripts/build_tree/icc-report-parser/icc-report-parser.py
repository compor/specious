#!/usr/bin/env python

import sys
import re


loop_start = '^LOOP BEGIN'
loop_end = '^LOOP END'
loop_par = 'LOOP WAS AUTO-PARALLELIZED'
benchmark_name = "4[0-9][0-9]\.\w"


def icc_report_parse():
    is_top_level_loop = False
    file_details = ''
    benchmark = ''
    filename = ''
    loop_line = ''
    loops = {}
    loop_count = 0


    for line in open(sys.argv[1]):
        if re.search(loop_start, line):
            is_top_level_loop = True
            parts = line.split()
            file_details = parts[3]

        # skip files that do not belong to the benchmark suite
        if not re.search(benchmark_name, file_details):
            continue

        if re.search(loop_end, line):
            is_top_level_loop = True
        
        if is_top_level_loop and re.search(loop_par, line):
            path_parts = file_details.split('/')

            for part in path_parts:
                if re.search(benchmark_name, part):
                    benchmark = part
                    break

            file_parts = path_parts[len(path_parts) - 1].split('(')
            filename = file_parts[0]
            loop_line = file_parts[1].split(',')[0]

            if len(loops) == 0:
                loops = { benchmark : { (filename, loop_line) } }
            else:
                loops[benchmark].update({ (filename, loop_line) })

    for k, v in loops.items():
        print '\n'
        print 'benchmark: ' + k
        loop_count = 0
        for loop in v:
            loop_count = loop_count + 1
            print "\t" + loop[0] + ':', loop[1]
        print 'benchmark:', k, ' parloops: ', loop_count





if __name__ == "__main__":
    icc_report_parse()

