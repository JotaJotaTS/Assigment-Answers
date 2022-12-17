require 'rest-client'
require 'bio'

class GFF
  def self.loadData(file)
        loadgenes= []
        File.foreach(file) do |gene|
            loadgenes.append(gene.strip().upcase())
        end
        return loadgenes
    end  

  def self.Exon_target_position(gene_name,seqTar)
    vsense=[]
    vreverse=[]
    target=Bio::Sequence.auto(seqTar)
    sen= target.to_re
    rev= target.reverse_complement
    rev= rev.to_re
    data_from_url = RestClient::Request.execute({
    method: :get,
    url: "http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene_name}"
    })
    embl_entry=Bio::EMBL.new(data_from_url)
    bioseq = embl_entry.to_biosequence
    
    for feature in embl_entry.features
      if feature.feature == "exon"
        match=feature.position.match(/(\d+)\.\.(\d+)/)
        start, stop= match[1].to_i, match[2].to_i
        exon=embl_entry.seq[start..stop]
        
    
        if exon.class!= NilClass
            tar_pos=exon.enum_for(:scan, sen).map{ Regexp.last_match.begin(0) } # I found this line of code in https://stackoverflow.com/questions/5241653/ruby-regex-match-and-get-positions-of
    
        
          if feature.position.include?('complement')==false 
          
            for init in tar_pos
              vsense.append("#{init+1}..#{init+seqTar.length()}") 
            end
          elsif feature.position.include?('complement') == true && exon
            for init in tar_pos
              vreverse.append("#{init+1}..#{init+seqTar.length()}") 
            end
        
          end
        end
      end
 
    end

    
    
    pair_gene_bseq=[gene_name, bioseq]
       
    return pair_gene_bseq,vsense.uniq,vreverse.uniq
  end
  
  

  
  def self.New_features( bio_seq, positions, seqTar)
        
        
    positions.each_with_index do |sites, ind|
      for j in sites
        if ind == 0
          strand = '+'
        else 
          strand = '-'
        end
          features_to_add = Bio::Feature.new('mutation_features', j)
          features_to_add.append(Bio::Feature::Qualifier.new('strand', strand))
          bio_seq.features << features_to_add
        end
      end
      return bio_seq
  end
  
  
  def self.Write_GFF3_exon_pos(file_name,bioseqs,seqTar, source=".",type="exon",score=".",phase=".") #how to write a gff3 fiel in https://learn.gencore.bio.nyu.edu/ngs-file-formats/gff3-format/#:~:text=General%20Feature%20Format%20(GFF)%20is,be%20handled%20by%20this%20format. 
   
    File.open("#{file_name}", 'w+') do |f|
      f.puts("##gff-version 3.2.1") #in the web page i found the format the version is 3.2.1
      for i in bioseqs
        for j in i[1].features
          if j.feature == 'mutation_features' 
            id = i[0]
            chromosome = i[1].primary_accession.split(":")[2] .to_i
            position = j.locations.first
            match=j.position.match(/(\d+)\.\.(\d+)/)
            start, endpos= match[1].to_i, match[2].to_i
            strand = j.assoc['strand']
            attributes = "ID= #{id}, Sequence_target= #{seqTar}" 
            f.puts("chr#{chromosome}\t#{source}\t#{type}\t#{start}\t#{endpos}\t#{score}\t#{strand}\t#{phase}\t#{attributes}")
          end
         end
      end
    end
  end
  
  def self.Write_GFF3_General_pos(file_name,bioseqs,seqTar, source=".",type="exon",score=".",phase=".") #how to write a gff3 fiel in https://learn.gencore.bio.nyu.edu/ngs-file-formats/gff3-format/#:~:text=General%20Feature%20Format%20(GFF)%20is,be%20handled%20by%20this%20format. 

    File.open("#{file_name}", 'w+') do |f|
      f.puts("##gff-version 3.2.1") #in the web page i found the format the version is 3.2.1
      for i in bioseqs
        for j in i[1].features
          if j.feature == 'mutation_features' 
            generalstart=i[1].primary_accession.split(":")[3].to_i
            id = i[0]
            chromosome = i[1].primary_accession.split(":")[2] .to_i
            position = j.locations.first
            match=j.position.match(/(\d+)\.\.(\d+)/)
            start, endpos= match[1].to_i + generalstart, match[2].to_i + generalstart
            strand = j.assoc['strand']
            attributes = "ID= #{id}, Sequence_target=#{seqTar}" 
            f.puts("chr#{chromosome}\t#{source}\t#{type}\t#{start}\t#{endpos}\t#{score}\t#{strand}\t#{phase}\t#{attributes}")
          end
         end
      end
    end
  end
  

  
  def self.NoMatchInExonReport(geneList,seqTar,file_name)
    vnomatchexon=[]
      for i in geneList
        expos=GFF.Exon_target_position(i, seqTar)
        if expos[1].length()==0 && expos[2].length()==0
          vnomatchexon.append(i)
        end
      end
    File.open(file_name, 'w')do |f|
      f.puts("REPORT BY JOSE JAVIER TEJEDA SANCHEZ\n\n") 
      f.puts("We found #{vnomatchexon.length()} sequences that don't contain '#{seqTar}' in their exons")
      f.puts("Those sequences are:\n\n")
      for i in vnomatchexon
        f.puts("\t-#{i}\n\n")
      end
    end
  end
    
    
end
