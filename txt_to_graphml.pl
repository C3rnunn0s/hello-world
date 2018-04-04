use strict;
use warnings;
use Data::Dumper;

my %species_list_h;
my %edge_list_h;
my @reactions_sort;
my @protlist_sort;

# define the text file containing the network information
# has to fit the structure:
# node1 \t {activation|inhibition} \t node2
my $file="./network_template.txt"; 

open (TXT,$file) or die $!;
###	building species list
my $sl_id=0;
my $re_id=0;
while (my $txt=<TXT>)
  {
  chomp $txt;
  
# build listOfIncludedSpecies
    if ($txt=~/^(.+)?\sactivation\s(.+)$/ || $txt=~/^(.+)?\sinhibition\s(.+)$/){
      if ($species_list_h{$1} && $species_list_h{$2}){
      }
    
      elsif($species_list_h{$1}){
	$sl_id++;
	$species_list_h{$2}=$sl_id;
      }
      elsif($species_list_h{$2}){
	$sl_id++;
	$species_list_h{$1}=$sl_id;
      }
      else{
	$sl_id++;
	$species_list_h{$2}=$sl_id;
	$sl_id++;
	$species_list_h{$1}=$sl_id;
      }
    }
  }
close TXT;


# build listOfReactions   
open (TXT,$file) or die $!."\n File could not be found!\n";
  while (my $txt2=<TXT>){
#   print "$txt2\n";
    my $edge;
    my @reac_type_a;
    my $reactand;
    my $product;
    if ($txt2=~/^(.+)?\sactivation\s(.+)/){
      $re_id++;
      $edge=$re_id;
      @reac_type_a=("standard","#008000");
      $reactand=$species_list_h{$1};
      $product=$species_list_h{$2};
      print "$product\n";
    }
    elsif ($txt2=~/^(.+)?\sinhibition\s(.+)/){
      $re_id++;
      $edge=$re_id;
      @reac_type_a=("t_shape","#FF0000");
      $reactand=$species_list_h{$1};
      $product=$species_list_h{$2};
    }
  
if (defined $edge && defined $reactand && defined $product)
    {
    my @reaction_complete=($reactand,$product,@reac_type_a);
    @{$edge_list_h{$edge}}=@reaction_complete;
#     push (@{$edge_list_h{$edge},($reactand,$product)});
#     $reactand=undef;
#     $product=undef;
#     @reac_type_a=undef;
    }
  }

@reactions_sort = sort { $a <=> $b } (keys %edge_list_h);

@protlist_sort = sort { $species_list_h{$a} <=> $species_list_h{$b} } (keys %species_list_h);
close TXT or die $!;

my $f1;
if ($file =~ /(\w.+)?(\.txt)$/){
  $f1 = $1;
}
open (OUT, ">./$f1.graphml") or die $!;

 
header();
Prot_sub();
Reac_sub();
close_out();
close OUT or die $!;
print "\nOutput was saved to \">./$f1.graphml\".\n\n";

###############################
##	subroutines for txt-to-graphml-converter
###############################
sub header {
print OUT '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:y="http://www.yworks.com/xml/graphml" xmlns:yed="http://www.yworks.com/xml/yed/3" xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns http://www.yworks.com/xml/schema/graphml/1.1/ygraphml.xsd">
  <!--Created by yFiles for Java 2.11-->
  <key for="graphml" id="d0" yfiles.type="resources"/>
  <key for="port" id="d1" yfiles.type="portgraphics"/>
  <key for="port" id="d2" yfiles.type="portgeometry"/>
  <key for="port" id="d3" yfiles.type="portuserdata"/>
  <key attr.name="url" attr.type="string" for="node" id="d4"/>
  <key attr.name="description" attr.type="string" for="node" id="d5"/>
  <key for="node" id="d6" yfiles.type="nodegraphics"/>
  <key attr.name="Beschreibung" attr.type="string" for="graph" id="d7"/>
  <key attr.name="url" attr.type="string" for="edge" id="d8"/>
  <key attr.name="description" attr.type="string" for="edge" id="d9"/>
  <key for="edge" id="d10" yfiles.type="edgegraphics"/>
  <graph edgedefault="directed" id="G">
    <data key="d7"/>';
}
  
sub Prot_sub {  

foreach my $prot_key(@protlist_sort)
{
print OUT '<node id="';
######################################

    print OUT 'n'.$species_list_h{$prot_key}.'">';
    

  #######################################

print OUT '<data key="d6">
        <y:ShapeNode>
          <y:Geometry height="30.0" width="30.0" x="275.0" y="271.0"/>
          <y:Fill hasColor="false" transparent="false"/>
          <y:BorderStyle color="#000000" type="line" width="1.0"/>
          <y:NodeLabel alignment="center" autoSizePolicy="content" fontFamily="Dialog" fontSize="12" fontStyle="plain" hasBackgroundColor="false" hasLineColor="false" height="17.96875" modelName="custom" textColor="#000000" visible="true" width="26.88671875" x="1.556640625" y="6.015625">'.$prot_key.'<y:LabelModel>
              <y:SmartNodeLabelModel distance="4.0"/>
            </y:LabelModel>
            <y:ModelParameter>
              <y:SmartNodeLabelModelParameter labelRatioX="0.0" labelRatioY="0.0" nodeRatioX="0.0" nodeRatioY="0.0" offsetX="0.0" offsetY="0.0" upX="0.0" upY="-1.0"/>
            </y:ModelParameter>
          </y:NodeLabel>
          <y:Shape type="rectangle"/>
        </y:ShapeNode>
      </data>
    </node>';
  }
}
  
sub Reac_sub {
foreach my $key_r(@reactions_sort)
  {
  my @re_data=@{$edge_list_h{$key_r}};
  print Dumper(\@re_data);
  if (defined $re_data[2])
    {
#     print "$key_r\n";
    print OUT '<edge id="e'.$key_r.'" source="n'.$re_data[0].'" target="n'.$re_data[1].'">
      <data key="d9"/>
      <data key="d10">
        <y:PolyLineEdge>
          <y:Path sx="0.0" sy="0.0" tx="0.0" ty="0.0">
            <y:Point x="552.0" y="365.0"/>
          </y:Path>
          <y:LineStyle color="'.$re_data[3].'" type="line" width="1.0"/>
          <y:Arrows source="none" target="'.$re_data[2].'"/>
          <y:BendStyle smoothed="false"/>
        </y:PolyLineEdge>
      </data>
    </edge>';
      }
    }
}

sub close_out {
print OUT '  </graph>
  <data key="d0">
    <y:Resources/>
  </data>
</graphml>';

}
