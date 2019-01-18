# use while loop

def dupRm_loop(s):

	m = len(s)

	i = 0
	while i < (m - 1):
		if s[i] == s[i+1]:
			s = s.replace(s[i+1], '', 1) # just replace one character
			m -= 1
		else:
			i += 1
	return(s)