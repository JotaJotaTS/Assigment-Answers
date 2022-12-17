require 'rest-client'
require 'set'
require 'json'

class Interaction_Network
       
    attr_accessor :gene
    attr_accessor :related_genes
    
    @@all_genes = {}
   

    def initialize(params = {})
        @gene = params.fetch(:gene, nil)
        @related_genes = params.fetch(:related_genes, [])
        
    end
    
    
    def self.loadData(file)
        loadgenes= []
        File.foreach(file) do |gene|
            loadgenes.append(gene.strip().upcase())
        end
        return loadgenes
    end   

    def self.Interactions(gene_name) #en el señorMayor es find_interaction y la variable en lo otro se llama locus_code
        data_from_url = RestClient::Request.execute({
    method: :get,
    url: "http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{gene_name}"
    })
      
        interactionvect = [] # en el señor mayor se llama interact_with_locus_code
                      
        
        for data in data_from_url.split("\n")
          
            gene = data.match(/(A[Tt]\d[Gg]\d\d\d\d\d)/) # In the column 2 of each record is located the Interaction
            
            if gene[0].upcase != gene_name.upcase && interactionvect.include?(gene[1].upcase) ==false
              interactionvect.append("#{gene[1].upcase}")
              
            end
            
            
            
        end
        @@all_genes["#{gene_name}"] = Interaction_Network.new(:gene => gene_name, :related_genes => interactionvect)
        return @@all_genes["#{gene_name}"]
    end
 
   
    def self.Relation_in_data(gene_name, all_genes)
      p=Interaction_Network.Interactions(gene_name).related_genes
      vnetwork=[gene_name]
      for i in p
        
        if all_genes.include? i
          
          vnetwork.append(i)
        end
          
      end
      return vnetwork
    end
    def self.All_rel_data(all_genes)
      allrelations=[]
      for i in all_genes
        p=Interaction_Network.Relation_in_data(i,all_genes)
        if p.length()>1
          allrelations.append(p)
        end
      end
      return allrelations
    end
  
  
    def self.All_networks(genes)
  inter=Interaction_Network.All_rel_data(genes)
  all_networks=[]
  all_networks2=[]
  for i in inter
  
    for j in i
      aux=[]
      aux.append(i[0])
      if j != i[0]
        aux.append(j)
      end
      if aux.length()>1
        all_networks2.append(aux)
        
      end
    end
  end
  all_networks.append(all_networks2)
  all_networks3=[]
  for i in all_networks2
  
    for j in all_networks2
      
      if i != j && j.include?(i[1])
        aux=i.dup
      all_networks[0].delete(aux)
        if i[1]!=j[0] && aux.include?(j[0])==false
          aux.append(j[0])
          all_networks3.append(aux)
          if all_networks[-1].include?(aux[-2..-1])  or all_networks[-1].include?(aux[-2..-1].reverse)
            all_networks[-1].delete(aux[-2..-1])
            all_networks[-1].delete(aux[-2..-1].reverse)
          end
          
        elsif i[1]!=j[1]
          aux.append(j[1]) && aux.include?(j[1])==false
          all_networks3.append(aux)
           if all_networks[-1].include?(aux[-2..-1])  or all_networks[-1].include?(aux[-2..-1].reverse)
            all_networks[-1].delete(aux[-2..-1])
            all_networks[-1].delete(aux[-2..-1].reverse)
          end
        end
      end
    
    
    end
  
  
  end

  for i in all_networks3
    all_networks3.delete(i.reverse)
  end
  all_networks3
  all_networks.append(all_networks3)
  
  all_networks=[]
  all_networks2=[]
  for i in inter
  
    for j in i
      aux=[]
      aux.append(i[0])
      if j != i[0]
        aux.append(j)
      end
      if aux.length()>1
        all_networks2.append(aux)
        
      end
    end
  end
  all_networks.append(all_networks2)
  all_networks3=[]
  for i in all_networks2
  
    for j in all_networks2
      
      if i != j && j.include?(i[1])
        aux=i.dup
        all_networks[0].delete(aux)
        if i[1]!=j[0] && aux.include?(j[0])==false
          aux.append(j[0])
          all_networks3.append(aux)
          if all_networks[-1].include?(aux[-2..-1])  or all_networks[-1].include?(aux[-2..-1].reverse)
            all_networks[-1].delete(aux[-2..-1])
            all_networks[-1].delete(aux[-2..-1].reverse)
          end
          
        elsif i[1]!=j[1]
          aux.append(j[1]) && aux.include?(j[1])==false
          all_networks3.append(aux)
           if all_networks[-1].include?(aux[-2..-1])  or all_networks[-1].include?(aux[-2..-1].reverse)
            all_networks[-1].delete(aux[-2..-1])
            all_networks[-1].delete(aux[-2..-1].reverse)
          end
        end
      end
    
    
    end
  
  
  end

  for i in all_networks3
    all_networks3.delete(i.reverse)
  end
  
  all_networks.append(all_networks3)
  
  n=4 #n is the number of genes in each interaction
  while n<genes.length()
    all_networksn=[]
  
    if all_networks[-1].length >= 1
    
      for i in all_networks[-1]
      
        for j in all_networks2
          
          if j.include?(i[-1])
            aux=i.dup
              
            if i[-1]!=j[0] && aux.include?(j[0])==false
              aux.append(j[0])
              all_networksn.append(aux)
              
            elsif i[-1]!=j[1] && aux.include?(j[1])==false
              aux.append(j[1])
              all_networksn.append(aux)
            end
          end
      
        
        end
      
        all_networks.append(all_networksn)
      
        break if all_networks[-1]==0
    
      end
 
    end
    n=n+1
  end
  
  all_networks.delete([])
  all_networks=all_networks.uniq


  for j in all_networks
    if j[0].length()>2
     for i in j
        j.delete(i.reverse)
      end
  
    end
  end
  
  for i in all_networks
  
    for x in i
    
        for j in all_networks
          if x.length < j[0].length()
            for z in j
            
              if x == z[0..x.length()-1] or x.reverse == z[0..x.length()-1] or x == z[-(x.length())..-1] or x.reverse == z[-(x.length())..-1]
               i.delete(x)
             
              end
              
            end
          
          end
         
        end
    
    end

  end


  
  
end
  
  
 
    def self.gene_ontology(gene_name)
       url_data =  RestClient::Request.execute({
          method: :get,
          url: "http://togows.dbcls.jp/entry/uniprot/#{gene_name}/dr.json"
          })
        gont = JSON.parse(url_data.body)[0]
        vgont=[]
  
        for go in gont["GO"]
          if go[1] =~ /P:/ #P means Process
            gov=go[0]
            process=go[1].delete("P:")
            vgont.append([gov,process])
          end
  
        end
          return vgont
    end

  
    def self.kegg(gene_name)
        url_data = RestClient::Request.execute({
        method: :get,
        url: "http://togows.org/entry/kegg-genes/ath:#{gene_name}/pathways.json"
        })
        kegg = JSON.parse(url_data.body)[0]
        return kegg
    end
    
    def self.GOandKegg(all_networks)
      info=[]
      for i in all_networks
        for j in i
          for k in j
            go=Interaction_Network.gene_ontology(k)
            keg=Interaction_Network.kegg(k)
            info.append([k,go,keg])
  
          end
        end
      
      
  
      end
      return info
    end
      

    def self.Report(all_networks, info,file_name)
      File.open(file_name, 'w')do |f|
        f.puts("REPORT BY JOSE JAVIER TEJEDA SANCHEZ\n")     
        for i in all_networks
          for j in i
            f.puts("*** Network: #{j.join("  ")} *** \n")
            for k in j
              z=0 #this value is to avoid repeats in the print
               for x in info
        
                  if x[0]==k && z==0
                    f.puts("\nGO of #{k}:\n\t#{x[1].join("\n\t" )}\n\n")
                    if x[2].length()>0            
                      f.puts("\nKEGG of #{k}:\n\t#{x[2]}\n\n")
                      
                    else
                      f.puts("\nKEGG of #{k}:\n\tThere's no kegg found for this gene")
                    end
                    z=1
                  end
            
          
                  
        
                end
     
              end
            
            end 
    
          end
        end
      
    end

    
  
  
end


