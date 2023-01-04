To execute this program you have to enter 2 variables the first one is the target file and the second the proteins file in the inverse order won't work.

The result is on a file called 'Orthologues_result.txt'


In this exercise I tryed to use the given data set, however they are so big files and the virtual machine stop working before the first blast was finished, so I had to create two small sample files for pep.fa (pep_sample.fa) and for TAIR10_cds_20101214_updated.fa (target_sample.fa), that have orthologues sequences to obtain a result file and can deliver this assigment.

I also upload a pep_sample.fa and target_sample.

Ex of use with the original data:

ruby BlastProgram.rb TAIR10_cds_20101214_updated.fa pep.fa

Example with my small data sets:

ruby BlastProgram.rb target_sample.fa pep_sample.fa
