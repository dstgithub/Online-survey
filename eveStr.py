### Read event file, convert each unique event to a single character ###
import csv
import re

def eveStr(path_file, conv_key):
    # read file
    with open(path_file, 'r') as f:
        reader = csv.reader(f)
        str_2d_list = list(reader)
  
    # initiate lists
    n_ele = len(str_2d_list)
    str_1d_list = [None] * n_ele
    new_str_1d_list = [0] * n_ele
    final_str_1d_list = [0] * n_ele
	
    # dimensionality reduction - original nested list of strings
    str_1d_list = [' '.join(map(str, s)) for s in str_2d_list]

    # function of replace muliple words in a single string
    def replace_ss(str_ori, substi):
        substrs = sorted(substi, key=len, reverse=True)
        rep_ss = re.compile('|'.join(map(re.escape, substrs)))
        return(rep_ss.sub(lambda match: substi[match.group(0)], str_ori))
	
    # apply inner function
    for i in range(n_ele):
	    new_str_1d_list[i] = replace_ss(str_1d_list[i], conv_key)
	    final_str_1d_list[i] = new_str_1d_list[i].replace(" ", "")

	# check the sum of the lengths of final strings,
	# to see whether it matches the total number of elements in the origianl list.
	# This does not apply to eveNames of single characters converting to char
	
    flattened_f_list = [y for x in str_2d_list for y in x]
    if '' in flattened_f_list:
        flattened_f_list.remove('')
	
    sum_len_ori_str = len(flattened_f_list)
    sum_len_final_str = len("".join(final_str_1d_list))
	
    if sum_len_final_str > sum_len_ori_str:
        print("Warning: One or more event names are not replaced by characters. Please check the original file and the conversion key.\n")
	
    return(final_str_1d_list)	
	