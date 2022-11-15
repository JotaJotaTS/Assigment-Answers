require 'csv'
class Gene
  attr_accessor :geneID, :geneName, :mutant
  @@genes=[]
  
  def initialize (params = {}) 
    @geneID = params.fetch(:geneID, 'gene Identifier')
    @geneName=params.fetch(:geneName, 'gene name')
    @mutant=params.fetch(:mutant, 'mutant type')
    
       
  end
    

  def self.load_from_file(file)
    gene_tab=CSV.read(file,col_sep: "\t", headers: true)
    @@genes=[]
    gene_tab.each() do |gene|
      #BONUS the unless test gene GeneID
      unless /^A[Tt]\d[Gg]\d\d\d\d\d$/.match(gene['Gene_ID'])
        abort("Sorry but the gene #{gene['Gene_name']} with ID: #{gene['Gene_ID']} doesn't have the correct format, please try again with the correct format or delete this gene" )
      end  
      @@genes.append(self.new(
      :geneID => gene['Gene_ID'],
      :geneName =>gene['Gene_name'] ,
      :mutant => gene['mutant_phenotype']))
    end
    return @@genes
  end
  
  def self.getName(id)
    for i in @@genes
      if i.geneID == id
        return i.geneName
      end
  
    end
    
    
  end

  
    
    
    
end


g= Gene.load_from_file(ARGV[0])




class Stock 
  attr_accessor :nameStock, :mutant_ID, :last_Planted, :storage, :grams
  @@seeds=[]
  def initialize (params = {}) 
   
    @nameStock = params.fetch(:nameStock, 'name seed stock')
    @mutant_ID =params.fetch(:mutant_ID, 'Mutant_Gene_ID')
    @last_Planted= params.fetch(:last_Planted, 'Last_Planted')
    @storage=params.fetch(:storage, 'Storage')
    @grams=params.fetch(:grams, 'Grams_Remaining').to_f
    
    
  end
  
  #BONUS Load from File
  def self.load_from_file(datafile)
    seed_tab=CSV.read(datafile,col_sep: "\t", headers: true)
    @@seeds=[]
    seed_tab.each() do |stock|
    
      @@seeds.append(self.new(
        :nameStock => stock['Seed_Stock'],
        :mutant_ID =>stock['Mutant_Gene_ID'],
        :last_Planted => stock['Last_Planted'],
        :storage =>stock['Storage'],
        :grams =>stock['Grams_Remaining']))
    end       
    return @@seeds, seed_tab
  end
  
  
    def self.getGeneID(name)
      for i in @@seeds
        if i.nameStock == name
          return i.mutant_ID
        end
  
      end
    end
    
    #BONUS object access individual SeedStock based on their ID
      
    def self.getStock(id)
      for i in @@seeds
        if i.nameStock == id
          return i
        end
  
      end
    
    end
  #BONUS the object has a write
  def self.return_new_file(new_file, seed_tab)
    
    for i in Array(0..seed_tab.length()-1)
      seed_tab[i][2]=  "8/2/2015"
  
      if (seed_tab[i][4]).to_i <= 7
        seed_tab[i][4]= 0
        puts "WARNING: we have run out of Seed Stock #{seed_tab[i][0]}"
        
    
      else
        
        seed_tab[i][4] =  seed_tab[i][4].to_i- 7
        
    
      end
    end


    File.open(new_file, "w+") {|file|  
  
      for i in Array(0..seed_tab.length()-1)
        for j in Array(0..seed_tab[0].length()-1)
          file.write("#{seed_tab[i][j]}\t") 
        end
          file.write("\n")
      end


    }
  end
    
    

end



#tryal bonus get stock from it ID
pb=Stock.getStock('A334')


seedstock=Stock.load_from_file(ARGV[1])
nuevo= Stock.return_new_file(ARGV[3],seedstock[1])

class Cross
    attr_accessor :P1, :P2,:P1ID, :P2ID,:F2W,:F2P1, :F2P2,:F2P1P2
    @@crosses=[]
  def initialize(params = {})
         
        @P1 = params.fetch(:P1)
        @P2 = params.fetch(:P2)
        @P1ID = params.fetch(:P1ID)
        @P2ID = params.fetch(:P2ID)
        @F2W = params.fetch(:F2W, nil)
        @F2P1 = params.fetch(:F2P1, nil)
        @F2P2 = params.fetch(:F2P2, nil)
        @F2P1P2 = params.fetch(:F2P1P2, nil)
  end
  def self.load_from_file(file)
    cross_tab=CSV.read(file,col_sep: "\t", headers: true)
    @@crosses=[]
    cross_tab.each() do |cross|
      
      @@crosses.append(self.new(
        :P1 => cross['Parent1'],
        :P2 =>cross['Parent2'],
        :P1ID => Gene.getName(Stock.getGeneID(cross['Parent1'])),
        :P2ID =>Gene.getName(Stock.getGeneID(cross['Parent2'])),
        :F2W => (cross['F2_Wild']).to_i,
        :F2P1 =>(cross['F2_P1']).to_i,
        :F2P2 =>(cross['F2_P2']).to_i,
        :F2P1P2 =>(cross['F2_P1P2']).to_i))
    end       
    return @@crosses
  end

  def self.chiSquare(cross)
  # in this cross we expect a distribution 9:3:3:1 
  # in other hand chi square is calculated as the sumatory of [(Observed-expected)^2 divided by the expected]
      total = cross.F2W + cross.F2P1+ cross.F2P2 + cross.F2P1P2 #Sumatory of all values
      expW = total * 9/16 
      expP1 = total * 3/16
      expP2 = total * 3/16
      expP1P2 = total * 1/16
      
      chisq = ( (cross.F2W - expW)**2/expW  +
                      (cross.F2P1- expP1)**2/expP1 +
                      (cross.F2P2 - expP2)**2/expP2 +
                      (cross.F2P1P2 - expP1P2)**2/expP1P2 )
  # the chi square table tell us that for a p-value of 0.05 we need at least a chi value of 7.815
      if chisq > 7.815
          puts "Recording: #{cross.P1ID} is genetically linked to #{cross.P2ID} with chi-square score of #{chisq}"
      end
  end
  
  
  
  
end


#j=Cross.load_from_file(ARGV[2])
j=Cross.load_from_file('cross_data.tsv')

for i in j
  Cross.chiSquare(i)
  
end










