require 'set'
require 'bio'



class Blast

  def self.createdb(seqfile) # Before start we have to create the database, to do that I search this method in https://sequenceserver.com/doc/
    system 'mkdir Database'
#to create the database I have to guess if the seqs are of a protein or a nucleotide,to do that I used the information on http://bioruby.org/rdoc/Bio/Sequence.html 
    sequence= Bio::Sequence.new(Bio::FlatFile.auto(seqfile).next_entry.seq)
    if sequence.guess == Bio::Sequence::AA
      system "cp #{seqfile} ./Database|cd Database|makeblastdb -dbtype prot  -title 'Target_db'  -parse_seqids -in Database/#{seqfile}"
    else
      system "cp #{seqfile} ./Database|cd Database|makeblastdb -dbtype nucl  -title 'Target_db'  -parse_seqids -in Database/#{seqfile}"
  
    end
  end
     
  def self.make_blast(type, database, query)
       vhits= [] #in this vector I will put the hits that meets the requirements
       blast=Bio::Blast.local(type,database)
       for seq in Bio::FlatFile.auto(query)
         report = blast.query(seq)
         report.each do |hit|
           if hit and hit.evalue 
#The params used for filter the hits are from this website https://www.metagenomics.wiki/tools/blast/evalue 
#the e value threshol is from this webpage as the e value threshold is for huge cuality hits, I use a bigger value,
# in other website I see a good hit has e value from 1e-10 and 1e-50 so I selected 1e-30. The link is https://resources.qiagenbioinformatics.com/manuals/clcgenomicsworkbench/650/_E_value.html#:~:text=The%20default%20threshold%20for%20the,most%20likely%20generate%20more%20hits.
#the bit score is from https://www.unmc.edu/bsbc/education/courses/gcba815/Week3_Blast.pdf
             if hit.evalue <= 1e-30 and hit.bit_score>40 
               vhits.append([seq.entry_id, hit.target_id])
               
             end
           end
        
         end 
      
      end
      return vhits
  end
end


