########## This script is created by Hong ##########
## to check the quality encodings for fastq files ##
#################### 2022-06-07 ####################

import sys
import numpy as np

def readFastq(fastqFile):
	"""
	Reads and parser the FASTQ file. 

	Parameters
	----------
	fastqFile - A FASTQ file.

	Returns
	------
	Generator object containing sequences. 
	"""
	i = 1
	name, seq, baseQ = None, [], []
	for line in fastqFile:
		if (line.startswith("@")) and (i%4 != 0):
			if name: yield (name, ''.join(seq), ''.join(baseQ))
			name, seq, baseQ = line, [], []
		if (line[0] in ['A', 'G', 'T', 'C', 'N']):
			seq.append(line)
		if (i%4 == 0):
			baseQ.append(line)
		i += 1
	if name: yield (name, ''.join(seq), ''.join(baseQ))	

if __name__ == "__main__":
    input_file = sys.argv[1]
    with open(input_file) as fastq:
        for name, seq, baseQ in readFastq(fastq):
            qualities = baseQ.strip()
            qual_scores = np.array([ord(q) for q in qualities])
            if np.any(qual_scores<64):
                if np.any(qual_scores<59):
                    print('Sanger encoding')
                    break
                else:
                    print('Solexa encoding')
                    break
        print('end of the file. If no other printed information, probabily illumina encoding')
