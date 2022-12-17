require './InteractionNetworkClass.rb'

genes=Interaction_Network.loadData(ARGV[0])


all=Interaction_Network.All_networks(genes)

todo= Interaction_Network.GOandKegg(all)

Interaction_Network.Report(all,todo,ARGV[1])


