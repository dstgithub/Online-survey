# use itertools

import itertools

def dupRm(s_list):

	return([''.join(ch for ch, _ in itertools.groupby(s)) for s in s_list])	