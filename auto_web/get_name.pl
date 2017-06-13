#!perl -w
    
$|=1;
use strict;   
use DBCORE;
use LWP::UserAgent;
use HTML::LinkExtractor;
use Data::Dump qw/dump/;
use LWP::Charset qw(getCharset);
use Encode qw/from_to/;

use DBCORE;
my $dbcore = new DBCORE({host=>"localhost",database=>"hpx",port=>"3306",user=>"root"});


my $raid=$dbcore->get_single_col("select distinct(stoid) from fi_sto where over=0 and has_name=0");

foreach(@$raid){	
	eval{
		my $zhu=getname($_);
		next unless $zhu;
		print $_,"=",$zhu,"\n";
		$dbcore->update_exec("update fi_sto set name=?,has_name=1 where stoid=?",[$zhu,$_]);
  };
	if($@){
		print "falure",$@;
	}
}



sub getname{
	my $id=shift;
	my $rh=fetch_page('http://jp.moneycentral.msn.com/investor/quotes/quotes.asp?Symbol='.$id);
	my $ok=$rh->{content};
	my $hui;
	eval{
	$ok=~s|\n||g;
	$ok=~s|\r||g;
	$ok=~s| ||g;
	$ok=~m/\<divclass=\"h1a\"\>(.*)\<\/div\>/;
	$ok=$1;
	$ok=~s/\<\/div\>.*//;

	$hui=$ok;
	from_to($hui, $rh->{"charset"}, "utf8");
	};
	if($@){
		die "zhu error";
	}
	return $hui;
}

sub fetch_page{
	my $url = shift;
	my $page;

   my $ua = LWP::UserAgent->new;
   $ua->timeout(10);
   $ua->env_proxy;
   my $response = $ua->get($url);
  if ($response->is_success) {
     return  {content=>$response->content,charset=>getCharset($response)||""};  # or whatever
  }
  else {
     return  undef;
  }
}
