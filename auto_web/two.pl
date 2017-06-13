#!/usr/bin/perl

use WWW::Mechanize;
use Math::Random qw(random_set_seed_from_phrase random_uniform_integer);
use Encode qw/from_to/;
use URI::Escape;
use HTML::LinkExtractor;
use LWP::UserAgent;



my $mech = WWW::Mechanize->new();
$mech->get( 'http://passport.baidu.com/?login' );
$mech->submit_form(
	form_number => 1,
    fields    => { username=>"baiduid",
    			password=>"password"}
);

#$mech->follow_link( n => 3 );
#$mech->follow_link( text_regex => qr/download this/i );
$mech->get('http://zhidao.baidu.com/browse/179?lm=2&pn=11');
#tolog("caonima.html", $mech->content(),1);

my $ra_links=get_url_from_page($mech->content());
my @newurl;
my $urltitle= {};
foreach(@$ra_links){
	if($_->{href} =~ m/question/){
		my $urlforget='http://zhidao.baidu.com'.$_->{href};
		push @newurl,$urlforget;
		$urltitle{$urlforget}=$_->{_TEXT};
		#tolog("monndayi.txt", $urlforget."\n".$_->{_TEXT});
	}
}
my @sen;
my $sleeptime;
    open G,"<sen.txt";
while(<G>){
	push @sen,$_;
}
close G;
foreach(@newurl){
	print $number,$_,"\n";
	my $rh=$mech->get($_);
	eval{
	$rh=$mech->submit_form(
	    form_name => 'fdf',
	    fields      => {
                #ct=>,
                #cm=>,
                #cid=>,
                #qid=>,
                #tn=>,
                co=>get_random_from_array([@sen]),
	});
	};
	$sleeptime= get_random_between(30,200);
	access('http://localhost:5558/self/filecms/baodu/add?subfromurl=1&data[url]='.$_.'&data[sleep]='.$sleeptime);
	print $sleeptime,"\n";
	sleep $sleeptime;
}
	
		
		
sub get_random_from_array{
	my $ra=shift;
	return $ra->[get_random_between(0,1*@$ra-1)];
}

sub get_random_between{
	my $from=shift;
	my $to=shift;
	my @num=random_uniform_integer(1, $from, $to);
	return $num[0];
}

sub tolog{
	my $filename=shift;
	my $content=shift;
	my $clear=shift;
	if($filename and $content){
		if($clear){
			open F, "> $filename";
		}else{
			open F, ">> $filename";
		}
		print F $content;
		print F "\n\n-----------------------------\n\n";
	}
}

sub get_url_from_page{
	my $page = shift;
	my $LX = new HTML::LinkExtractor(undef ,undef ,1);
    $LX->parse(\$page);
	my $ra =  $LX->links;

    return $ra;
}


sub access{
	my $url=shift;
	
	 # Create a user agent object
	 
	  $ua = LWP::UserAgent->new;
	  $ua->agent("MyApp/0.1 ");

	  # Create a request
	  my $req = HTTP::Request->new(GET => $url);
	  $req->content_type('application/x-www-form-urlencoded');
	  $req->content('query=libwww-perl&mode=dist');

	  # Pass request to the user agent and get a response back
	  my $res = $ua->request($req);

	  # Check the outcome of the response
	  if ($res->is_success) {
	      return $res->content;
	  }
	  else {
	      return $res->status_line;
	  }
}
