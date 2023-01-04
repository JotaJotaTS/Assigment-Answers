require './Class_blast.rb'


seqa=ARGV[0] #the target
seqb=ARGV[1] #the protein


Blast.createdb(seqa)

seqadb = "Database/#{File.basename(seqa)}"

seqablast=Blast.make_blast('tblastn',seqadb,seqb)

#As we are looking for ortologues that are genes similar in both species and our database is hughe and needs lots of time,
#I will create an auxiliar File only with the hits in the previous blast, and this file will be used for the 
#reciprocal blast database

File.open('Aux.txt', 'w+') do |file|
  for seq in Bio::FlatFile.auto(seqa)
    for i in seqablast
      if i.include?(seq.entry_id)
        file.puts(seq)
        file.puts("\n")
      end
    end
  end
end



Blast.createdb(seqb)

seqbdb = "Database/#{File.basename(seqb)}"

seqbblast=Blast.make_blast('blastx',seqbdb,'Aux.txt')

File.open('Orthologues_result.txt', 'w+') do |file|
  file.puts("ORTHOLOGUES RESULTS \n\nby Jose Javier Tejeda Sanchez\n\n")
  
  for i in seqablast
    for j in seqbblast
      if i[1]==j[0] and j[1].include?(i[0])
        file.puts("\t#{i[0]} -- #{j[0]}")
        file.puts("\n\n")
      end
    end
  end
end

File.delete('Aux.txt')


