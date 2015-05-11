# FuzzyCluster
matlab code of fuzzy cluster algorithm

Usage (e.g.):
fuzzycluster("input_raw_data.txt", "C:\output_data", 0.7)

INPUT:
In input_raw_data.txt, each line is a vector that represents a sample. N lines just mean N samples to cluster.

OUTPUT:
In final group result, each line is clustered as a group. N lines just mean N groups. Numbers in each group are just the indexes in the raw data, e.g. if result has '2 6' in the same line, then sample 2 and sample 6 are clustered in the same group.
It will output the final group result and intermediate files to path 'C:\output_data' using file names like the following:
step1_normalized_data.txt
step2_similarity_data.txt
step3_transitive_closure.txt
step4_cut_matrix_lamda_0.7.txt
step5_final_group_result_lamda_0.7.txt

step1~4 are intermediate files for verification, step5 are the final group result.
