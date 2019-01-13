import pandas as pd

def commonPatt(string_list, low = 10):

	# number of strings in the list
	num_str = len(string_list)

	### pattern and percent - all count
	# all substrings
	sp7 = [s[i:i+m] for s in string_list for m in range(3, len(s)+1) for i in range(0, len(s)-m+1)]

	# count the number of each substring, and store in a data frame
	df7 = pd.DataFrame(sp7, columns=['patt'])
	df7 = pd.value_counts(df7['patt']).to_frame().reset_index()

	df7.columns = ['Pattern','Freq_grp']

	# percent in decimal and %
	Perc_grp = df7.loc[:, 'Freq_grp']  / num_str
	df7['Percent_grp'] = pd.Series(['{0:.1f}%'.format(x * 100) for x in Perc_grp])

	# length of each substring
	df7['Length'] = df7['Pattern'].astype(str).map(len)

	# sort
	df7sort = df7.sort_values(['Pattern'], ascending=[True])


	### pattern and percent - unique in each string

	# function to define how to obtain unique substrings from a single string
	def unil_sub(s):
	    s1 = [s[i:i+m] for m in range(3, len(s)+1) for i in range(0, len(s)-m+1)]
	    s1u = list(set(s1))
	    return(s1u) # return list

	# apply function for multiple strings  
	s7_s1ul = [unil_sub(s) for s in string_list] # list of two lists 

	# merge two (multiple) lists of substrings
	sl7 = sum(s7_s1ul, []) 

	# count the number of each substring, and store in a data frame
	dfu7 = pd.DataFrame(sl7, columns=['pattu'])
	dfu7 = pd.value_counts(dfu7['pattu']).to_frame().reset_index()

	dfu7.columns = ['Patternu','Freq_str']

	# percent in decimal and %
	Perc_str = dfu7.loc[:, 'Freq_str']  / num_str
	dfu7['Percent_str'] = pd.Series(['{0:.1f}%'.format(x * 100) for x in Perc_str])

	# sort
	dfu7sort = dfu7.sort_values(['Patternu'], ascending=[True])


	### combine df7sort and dfu7sort
	df7sort['Freq_str'] = dfu7sort['Freq_str']
	df7sort['Percent_str'] = dfu7sort['Percent_str']

	# cutoff frequency
	# note 'low' is the pre-defined or user-defined low cutoff. e.g., default low = 10 
	low_freq = low * num_str / 100

	# filter
	df7sortf =  df7sort[df7sort['Freq_grp'] >= low_freq]

	# grand sort
	df7sortfs = df7sortf.sort_values(['Length', 'Freq_grp'], ascending=[False, False])

	print(df7sortfs.to_string(index=False))

