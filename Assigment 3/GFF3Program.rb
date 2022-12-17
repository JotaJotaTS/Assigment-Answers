require './GFF3class.rb'

target= ARGV[0]
inputfile=ARGV[1]

genes=GFF.loadData(inputfile)

bioseqs=[]
  
for i in genes
    expos=GFF.Exon_target_position(i, target)
    if expos[1].length()!=0 or expos[2].length()!=0
      bioseqs.append(expos[0])
      GFF.New_features(expos[0][1], [expos[1],expos[2]], target)
    end
end


GFF.Write_GFF3_exon_pos('pos_in_exon.gff3',bioseqs,target)

GFF.Write_GFF3_General_pos('pos_in_gene.gff3',bioseqs,target)

GFF.NoMatchInExonReport(genes,target, 'No_Matches_Report.txt')


