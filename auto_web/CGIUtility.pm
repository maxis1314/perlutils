package CGIUtility;
use MIME::Base64;
use URI::Escape;
use Data::Dump qw/dump/;
use FileHandle;
use Storable;

#use PageApart;

use constant NEW_FILE_SIZE => 10000000;

BEGIN{
	use Exporter();
	@ISA = qw(Exporter);
	@EXPORT = qw(&add_log &print_anything &print_anything_html &store_into_file &retrive_from_file &see_bug);
	@EXPORT_OK = qw(&array_sub_array 
					&array_and_array 
					&array_add_array 
					&get_file_stat
					&parser_path
					&get_dir_file_due_to_head
					&get_dir_file_due_to_tail
					&get_dir_file_contain
					&get_only_names
					&encode_hash
					&encode_array
					&decode_hash
					&decode_array
					&decode_item
					&ecode_item
					&sort_array_hash_string
					&sort_array_hash_int
					&reverse_array
					&date
					&set_to_tmpl
					&save_to_session
					&get_from_client
					&clear_session
					&get_from_session
					&need_map_array
					&print_view_input_info
					&print_view_session_info
					&sort_and_reverse_array
					&print_cvs
					&process_page_apart_and_sort
					&process_page_apart_and_sort_all_data
					&unique_array
					&is_in_array
					&store_config_file
					&retrive_config_file);
}

$VERSION = 1.33;

#00001
#++++++++++++++++++check area++++++++++++++++++++
#cutting
#----------------------------------------------
#00002
#++++++++++++++++++utility area++++++++++++++++++++
#compare two string values undef is smaller
#----------------------------------------------
sub compare_string{
	my $item1 = shift;
	my $item2 = shift;
	if(!defined($item1) and !defined($item2)){
		return 0;
	}
	if(defined($item1) and !defined($item2)){
		return 0;
	}
	if(!defined($item1) and defined($item2)){
		return 1;
	}
	return int ($item1 lt $item2);
}

#compare two int undef is smaller
#----------------------------------------------
sub compare_int{
	my $item1 = shift;
	my $item2 = shift;
	if(!defined($item1) and !defined($item2)){
		return 0;
	}
	if(defined($item1) and !defined($item2)){
		return 0;
	}
	if(!defined($item1) and defined($item2)){
		return 1;
	}
	return int ($item1 < $item2);
}

#get sub array according to page number and items per page
#----------------------------------------------
sub get_sub_array{
	my($ra_array, $page_num, $item_num_page) = @_;
	my @new_array;
	my $length_array = get_array_num_by_ref($ra_array);
	my $count = $page_num * $item_num_page;
	while($item_num_page-- && ($count-$item_num_page) <= $length_array){
		push @new_array, $ra_array->[$count-$item_num_page-1];
	}
	return \@new_array;	
}

#get elements number of an array
#----------------------------------------------
sub get_array_num_by_ref{
	my($ra_array) = @_;
	if(!defined($ra_array)){
		return 0;
	}
	return 1*@{$ra_array};
}

#get a random number given from number and to number
#----------------------------------------------
sub get_random_num_from_to{
	my($from, $to) = @_;	
	srand; 
	my $int=rand($to-$from+1);  
	$int=int(rand($to-$from+1));
	return $int + $from;
}

#get a sub hash given the fields required
#----------------------------------------------
sub get_sub_hash{
	my ($rh_hash, $ra_fields) = @_;
	my %new_hash;
	my $length_array = get_array_num_by_ref($ra_fields);
	if($length_array == 0){
		return undef;
	}
	foreach(@{$ra_fields}){
		$new_hash{$_} = $rh_hash->{$_};
	}
	return \%new_hash;
	
}

#insert some fields with values into the exist hash 
#----------------------------------------------
sub insert_into_hash{
	my ($rh_hash, $ra_fields, $ra_value) = @_;
	my $length_array = get_array_num_by_ref($ra_fields);
	if($length_array == 0){
		return $rh_hash;
	}
	foreach(1..$length_array){
		$rh_hash->{$ra_fields->[$_ - 1]} = $ra_value->[$_ - 1];
	}
	return $rh_hash;	
}

#delete some fields in the hash
#----------------------------------------------
sub delete_from_hash{
	my ($rh_hash, $ra_fields) = @_;
	my %new_hash;
	my $length_array = get_array_num_by_ref($ra_fields);
	if($length_array == 0){
		return $rh_hash;
	}
	foreach(keys %{$rh_hash}){
		if(is_in_array($ra_fields, $_) == 0){
			$new_hash{$_} = $rh_hash->{$_};
		}		
	}
	return \%new_hash;	
}

#get the hash values array reference
#----------------------------------------------
sub get_ra_hash_value_by_key{
	my ($ra_hash, $key) = @_;
	my @value;
	my $length_array = get_array_num_by_ref($ra_hash);
	if($length_array == 0){
		return [];
	}
	foreach(@$ra_hash){
		if(is_in_hash_keys($_, $key) == 1){
			push @value, $_->{$key};
		}
	}
	return \@value;
}

#delete some fields from array
#----------------------------------------------
sub delete_from_array{
	my ($ra_array, $ra_fields) = @_;
	my @new_array;
	my $length_array = get_array_num_by_ref($ra_fields);
	if($length_array == 0){
		return $ra_array;
	}
	foreach(@{$ra_array}){
		if(is_in_array($ra_fields, $_) == 0){
			push @new_array, $_;
		}		
	}
	return \@new_array;	
}

#judge whether an element is in an array, 1-in array
#----------------------------------------------
sub is_in_array{
	my ($ra_array, $item) = @_;
	my $length_array = get_array_num_by_ref($ra_array);
	if($length_array == 0){
		return 0;
	}
	foreach(1..$length_array){
		if($item and $ra_array->[$_ - 1] and $ra_array->[$_ - 1] eq $item){
			return 1;
		}
	}
	return 0;
}

#judge whether an element is in the hash's keys
#----------------------------------------------
sub is_in_hash_keys{
	my ($rh_hash, $item) = @_;
	foreach(keys %{$rh_hash}){
		if($_ eq $item){
			return 1;
		}
	}
	return 0;
}

#judge whether an element is in the hash's values
#----------------------------------------------
sub is_in_hash_values{
	my ($rh_hash, $item) = @_;
	foreach(keys %{$rh_hash}){
		if($rh_hash->{$_} eq $item){
			return 1;
		}
	}
	return 0;
}

#judge whether the two simple array is same
#----------------------------------------------
sub array_eq{
	my ($ra_array1, $ra_array2) = @_;
	my $length_array1 = get_array_num_by_ref($ra_array1);
	my $length_array2 = get_array_num_by_ref($ra_array2);
	if($length_array1 == 0 && $length_array2 == 0 ){
		return 1;
	}elsif($length_array1 == $length_array2 && $length_array1 != 0){
		foreach(1..$length_array1){
			if($ra_array1->[$_ - 1] ne $ra_array2->[$_ - 1]){
				return 0;
			}
		}
		return 1;
	}else{
		return 0;
	}	
}

#judge whether two hash is the same
#----------------------------------------------
sub hash_eq{
	my ($rh_hash1, $rh_hash2) = @_;
	my @key_array1 = sort keys(%$rh_hash1);
	my @key_array2 = sort keys(%$rh_hash2);
	if(array_eq(\@key_array1, \@key_array2) == 0){
		return 0;
	}
	foreach(keys %{$rh_hash1}){
		if($rh_hash1->{$_} eq $rh_hash2->{$_}){
			return 0;
		}
	}
	return 1;
}

#judge whether first hash is in the second hash
#----------------------------------------------
sub is_hash_in_hash{
	my ($rh_hash1, $rh_hash2) = @_;
	my @key_array1 = sort keys(%$rh_hash1);
	my @key_array2 = sort keys(%$rh_hash2);

	my $length_array1 = get_array_num_by_ref(\@key_array1);
	my $length_array2 = get_array_num_by_ref(\@key_array2);
	if($length_array1 == 0 && $length_array2 == 0 ){
		return 1;
	}
	
	if(is_array_in_array(\@key_array1, \@key_array2) == 0){
		return 0;
	}
	
	foreach(keys %{$rh_hash1}){
		if($rh_hash1->{$_} ne $rh_hash1->{$_}){
			return 0;
		}
	}
	return 1;	
}

#judge where first array is in the second array
#----------------------------------------------
sub is_array_in_array{
	my ($ra_array1, $ra_array2) = @_;
	my $cursor = 0;
	my $length_array1 = get_array_num_by_ref($ra_array1);
	my $length_array2 = get_array_num_by_ref($ra_array2);
	if($length_array1 == 0 && $length_array2 == 0 ){
		return 1;
	}elsif($length_array1 <= $length_array2 && $length_array1 > 0){		
		foreach(1..$length_array1){
			while($ra_array1->[$_ - 1] ne $ra_array2->[$cursor++]){
				if(($length_array1 - $_ + 1) > ($length_array2 - $cursor)){
					return 0;
				} 
			}			
		}
		return 1;
	}else{
		return 0;
	}	
}

#make an item into a array contains only one element
#----------------------------------------------
sub make_array{
	my ($item) = @_;
	return [$item];
}

#judge whether two elements is the same
#----------------------------------------------
sub ok{
	my ($r_one, $r_two, $str_func) = @_;
	if(is_all_same($r_one, $r_two) == 1){
		print "OK -- ".$str_func."\n";
	}	
}

#judge whether two items is the same
#----------------------------------------------
sub is_all_same{
	my ($r_one, $r_two) = @_;
	if(!defined($r_one) and !defined($r_two)){
		return 1;
	}
	unless(defined($r_one) and defined($r_two)){
		return 0;
	}
	if(ref($r_one) ne ref($r_two)){
		return 0;
	}
	if(ref($r_one) eq 'ARRAY'){
		if(is_array_size_eq($r_one, $r_two) == 0){
			return 0;
		}
		foreach(1..get_array_num_by_ref($r_one)){
			if(!is_all_same($r_one->[$_ - 1], $r_two->[$_ - 1])){
				return 0;
			}
		}
		return 1;		
	}
	if(ref($r_one) eq 'HASH'){
		if(is_hash_size_key_eq($r_one, $r_two) == 0){
			return 0;
		}
		foreach(%{$r_one}){
			if(!is_all_same($r_one->{$_}, $r_two->{$_})){
				return 0;
			}
		}
		return 1;	
	}
	if($r_one eq $r_two){
		return 1;
	}
	return 0;
}

#see if the size of two array is the same
#----------------------------------------------
sub is_array_size_eq{
	my ($ra_array1, $ra_array2) = @_;
	my $length_array1 = get_array_num_by_ref($ra_array1);
	my $length_array2 = get_array_num_by_ref($ra_array2);
	if($length_array1 == $length_array2){
		return 1;
	}
	return 0;	
}

#see if the keys of two hashs is the same
#----------------------------------------------
sub is_hash_size_key_eq{
	my ($rh_one, $rh_two) = @_;
	my @key_one = sort keys(%$rh_one);
	my @key_two = sort keys(%$rh_two);
	return array_eq(\@key_one, \@key_two);
}

#return a string when you give a variable
#----------------------------------------------
sub to_string{
	$string = "";
	to_string_loop("",shift,0);
	return $string;
}

#function used by to_string()
#----------------------------------------------
sub to_string_loop{#($r_, $layer)
	my($head, $r_unknow, $layer)= @_; 
	print_space($layer);
	if(defined($head)){
		$string.=$head;
	}
	if(ref($r_unknow) eq 'HASH'){		
		$string.="HASH_REF\n";
		$layer++;
		foreach(keys %{$r_unknow}){
			to_string_loop('|'.$_.'=>', $r_unknow->{$_} ,$layer);
		}
	}elsif(ref($r_unknow) eq 'ARRAY'){
		$string.="ARRAY_REF\n";
		$layer++;
		foreach(@{$r_unknow}){
			to_string_loop('|', $_ ,$layer);
		}
	}else{
		if(defined($r_unknow)){
			$string.=$r_unknow."\n";
		}else{
			$string.="undef"."\n";
		}
	}
}

#make the tail shorter
#------------------------------------------------
sub chop_char{
	my ($string, $num) = @_;
	while($string ne "" and $num--){
		chop($string);
	}
	$string;
}

#make two array into one
#----------------------------------------------
sub merge_array{
	my ($ra_ra_array) = @_;
	my @new_array;
	my $length = get_array_num_by_ref($ra_ra_array);
	if($length == 0){
		return \@new_array;
	}
	for my $item(1..$length){
		my $array_lebgth = get_array_num_by_ref($ra_ra_array->[$item - 1]);
		if($array_lebgth == 0){
			next;
		}
		for(1..$array_lebgth){
			push @new_array, $ra_ra_array->[$item - 1]->[$_ - 1];
		}
	}
	return \@new_array;
}

#make two hash into one(filter the same keys)
#----------------------------------------------
sub merge_hash{
	my ($ra_rh_hash) = @_;
	my %new_hash;
	my $count = 0;
	my $length = get_array_num_by_ref($ra_rh_hash);
	if($length == 0){
		return \%new_hash;
	}
	for my $item(1..$length){
		foreach(keys %{$ra_rh_hash->[$item - 1]}){
			if(exists $new_hash{$_}){
				$new_hash{$_."--repeated".$count++} = $ra_rh_hash->[$item - 1]->{$_};
			}else{
				$new_hash{$_} = $ra_rh_hash->[$item - 1]->{$_};
			}
		}		
	}
	return \%new_hash;
}

#parth the path into parts
sub parser_path{
	my ($file_full_address) = @_;
	$file_full_address =~ m/(.*[|\/])*(.+)\.(.+)$/;
	my %result;
	$result{'where'} = defined($1)?$1:"";
	$result{'name'} = defined($2)?$2:"";
	$result{'ext'} = defined($3)?$3:"";
	$result{'file_name'} = $result{'name'}.".".$result{'ext'};
	return \%result;	
}

#get files begin with something
sub get_dir_file_due_to_head{
	my ($path, $head) = @_;
    @result = glob "$path$head*";
	return \@result;
}

#get files end with something
sub get_dir_file_due_to_tail{
	my ($path, $tail) = @_;
	@result = glob "$path*$tail\.*";
	return \@result;
}

#get files contain with something
sub get_dir_file_contain{
	my ($path, $mid) = @_;
	@result = glob "$path*$mid*\.*";
	return \@result;
}

#get file names only 
#-------------------------------------------
sub get_only_names{
	my ($ra_files) = @_;
	my @file_name;
	foreach(@$ra_files){
		push @file_name, parser_path($_)->{'file_name'};
	}
	return \@file_name;
}

#for every member in the array,we add a head
#----------------------------------------------------------
sub add_head_to_array{
	my ($ra_array, $head) = @_;
	my $length_array = get_array_num_by_ref($ra_array);
	if($length_array == 0){
		return 0;
	}
	my @new_array;
	foreach(@$ra_array){
		push @new_array, $head."".$_;
	}
	return \@new_array;
}

#for every member in the array,we add a tail
#----------------------------------------------------------
sub add_tail_to_array{
	my ($ra_array, $tail) = @_;
	my $length_array = get_array_num_by_ref($ra_array);
	if($length_array == 0){
		return 0;
	}
	my @new_array;
	foreach(@$ra_array){
		push @new_array, $_."".$tail;
	}
	return \@new_array;
}

#for every member in the array,we trim a head
#----------------------------------------------------------
sub trim_head_from_array{
	my ($ra_array, $head) = @_;
	my $length_array = get_array_num_by_ref($ra_array);
	if($length_array == 0){
		return 0;
	}
	my @new_array;
	foreach(@$ra_array){
		if(m/^($head)(.*)/){
			push @new_array, $2;
		}
	}
	return \@new_array;
}

#for every member in the array,we trim a tail
#----------------------------------------------------------
sub trim_tail_from_array{
	my ($ra_array, $tail) = @_;
	my $length_array = get_array_num_by_ref($ra_array);
	if($length_array == 0){
		return 0;
	}
	my @new_array;
	foreach(@$ra_array){
		if(m/(.*)($tail)$/){
			push @new_array, $1;
		}
	}
	return \@new_array;
}

#check year month and day
#----------------------------------------------------------
sub check_year_month_day{
	my ($year, $month, $day) = @_;
	unless($year =~ /^\d+$/ and
	       $month =~ /^\d+$/ and
	       $day =~ /^\d+$/){
	       	return 0;
	}
	my $numOfDays = 0;
	my $tag = 0;
	if($year%100 == 0&&$year%400==0){
		$tag =1;
	}
	if($year%4==0&&$year%100!=0){
		$tag =1;
	}
	if($month==1||$month==3||$month==5||$month==7||$month==8||$month==10||$month==12){
		$numOfDays = 31;
	}elsif($month!=2){
		$numOfDays = 30;
	}else{
		$numOfDays = $tag ==1?29:28;
	}
	
	if($month > 12 or $day > $numOfDays){
		return 0;
	}
	return 1;
}

#encode the hash
sub encode_hash{
	my $rh = shift;
	foreach(keys %$rh){
		$rh->{$_} = uri_escape(encode_base64($rh->{$_}));		
	}
	return $rh;
}

#encode the array
sub encode_array{
	my $ra = shift;
	foreach(1..1*@$ra){
 		$ra->[$_ - 1] = uri_escape(encode_base64($ra->[$_ - 1]));
	}
	return $ra;
}

#decode the hash
sub decode_hash{
	my $rh = shift;
	foreach(keys %$rh){
		$rh->{$_} = decode_base64(uri_unescape($rh->{$_}));
	}
	return $rh;
}

#decode the array
sub decode_array{
	my $ra = shift;
	foreach(1..1*@$ra){
 		$ra->[$_ - 1] = decode_base64(uri_unescape($ra->[$_ - 1]));
	}
	return $ra;
}

#decode item
sub decode_item{
	my $item = shift;	
 	return decode_base64(uri_unescape($item));	
}

#ecode item
sub ecode_item{
	my $item = shift;	
 	return uri_escape(encode_base64($item));	
}

#get all files in the directory
sub files_in_dir{
	my $path = shift;
	opendir(DIR, $path); 
	@files = readdir(DIR);
	return \@files;
}

#get the qualified members of an array 
sub fetch_array{
	my $ra = shift;
	my $ok = shift;
	my @new_array;
	foreach(@$ra){
		if(&$ok($_)){
			push @new_array, $_;
		}
	}
	return \@new_array;
}

#get the qualified members of an array 
sub filter_array{
	my $ra = shift;
	my $ok = shift;
	my @new_array;
	foreach(@$ra){
		if(!(&$ok($_))){
			push @new_array, $_;
		}
	}
	return \@new_array;
}

#get the qualified members of a hash
sub fetch_hash{
	my $rh = shift;
	my $ok = shift;
	my %new_hash;
	foreach(keys %$rh){
		if(&$ok($rh->{$_})){
			$new_hash{$_} = $rh->{$_};
		}
	}
	return \%new_hash;
}

#get the qualified members of a hash
sub filter_hash{
	my $rh = shift;
	my $ok = shift;
	my %new_hash;
	foreach(keys %$rh){
		if(!(&$ok($rh->{$_}))){
			$new_hash{$_} = $rh->{$_};
		}
	}
	return \%new_hash;
}

#sort the array provided an fuction of compare two members
sub sort_array{
	my $ra = shift;
	my $compare = shift;
	my $length = get_array_num_by_ref($ra);
	foreach my $i(1..$length){
		foreach my $j(($i + 1)..$length){
			if(&$compare($ra->[$i - 1], $ra->[$j - 1])){
				my $temp = $ra->[$i - 1];
				$ra->[$i - 1] = $ra->[$j - 1];
				$ra->[$j - 1] = $temp;
			}
		}
	}
	return $ra;
}

#sort array due to string
sub sort_array_string{
	my $ra = shift;
	my $compare = \&compare_string;
	return sort_array($ra, $compare);
}

#sort array due to int
sub sort_array_int{
	my $ra = shift;
	my $compare = \&compare_int;
	my $length = get_array_num_by_ref($ra);
	return sort_array($ra, $compare);
}

#sort array hash due to string
sub sort_array_hash_string{
	my $ra = shift;
	my $field = shift;
	my $compare = \&compare_string;
	return sort_array_hash($ra, $field, $compare);
}

#sort array hash due to int 
sub sort_array_hash_int{
	my $ra = shift;
	my $field = shift;
	my $compare = \&compare_int;
	return sort_array_hash($ra, $field, $compare);
}

#sort array hash given a function to copare two members
sub sort_array_hash{
	my $ra = shift;
	my $field = shift;
	my $compare = shift;
	my $length = get_array_num_by_ref($ra);
	foreach my $i(1..$length){
		foreach my $j(($i + 1)..$length){
			if(&$compare($ra->[$i - 1]->{$field}, $ra->[$j - 1]->{$field})){
				my $temp = $ra->[$i - 1];
				$ra->[$i - 1] = $ra->[$j - 1];
				$ra->[$j - 1] = $temp;
			}
		}
	}
	return $ra;
}

#reverse an array
sub reverse_array{
	my $ra = shift;
	my @array = @$ra;
	@array = reverse @array;
	return \@array;
}

#upload file
sub upload_file{
	my $file_h = shift;
	my $to_file = shift;
	my $buffer = "";
	binmode $file_h;
	open(F, ">", $to_file);
	binmode F;
	while(read($file_h, $buffer, 1024*1024)){
		print F $buffer;
	}
	close F;
}

#operation on array members
sub operation_on_array_member{
	my $ra = shift;
	my $operation = shift;
	my $length = get_array_num_by_ref($ra);
	foreach my $i(1..$length){
		$ra->[$i - 1] = &$operation($ra->[$i - 1]);
	}
	return $ra;
}
sub operation_on_hash_member{
	my $rh = shift;
	my $operation = shift;
	foreach (keys %$rh){
		$rh->{$_} = &$operation($rh->{$_});
	}
	return $rh;
}

sub date{
    my($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    $year = $year + 1900;    
    my $ampm = "am";
    if ($hour > 11) { $ampm = "pm"; }
    return {year=>$year, month=>$mon + 1, day=>$mday, hour=>$hour, 
		min=>$min, sec=>$sec, ampm=>$ampm,
		string=>$year.'-'.($mon + 1).'-'.$mday.'-'.$hour.'-'.$min.'-'.$sec,
		string2=>$year.'-'.($mon + 1).'-'.$mday.' '.$hour.':'.$min.':'.$sec,
		string3=>$year.'-'.((($mon + 1)<10)?'0'.($mon + 1):($mon + 1)).'-'.($mday<10?'0'.$mday:$mday).' '.($hour<10?'0'.$hour:$hour).':'.($min<10?'0'.$min:$min).':'.($sec<10?'0'.$sec:$sec),
		string4=>$year.'-'.((($mon + 1)<10)?'0'.($mon + 1):($mon + 1)).'-'.($mday<10?'0'.$mday:$mday),
	};
}
sub copy_in_array{
	my $ra = shift;
	my $from = shift;
	my $to = shift;
	my $length = shift;
	$from -= 1;
	$to -= 1;
	my $end = $from + $length;
	if($end > $to and $end < ($to + $length)){
		foreach(1..$length){
			$ra->[$to + $length - $_] = $ra->[$from + $length - $_];
		}
	}else{
		foreach(1..$length){
			$ra->[$to + $_ - 1] = $ra->[$from + $_ - 1];
		}
	}
	return $ra;
}
sub sub_array_from_to{
	my $ra = shift;
	my $from = shift;
	my $to = shift;
	my @array;
	my $length = get_array_num_by_ref($ra);
	if($from < 1){
		$from = 1;
	}
	if($from > $length and $from > $to){
		return [];
	}
	if($to > $length){
		$to = $length;
	}
	foreach($from..$to){
		push @array, $ra->[$_ - 1];
	}
	return \@array;
}
sub head_array{
	my $ra = shift;
	my $length = shift;
	return sub_array_from_to($ra, 1, $length);
}
sub tail_array{
	my $ra = shift;
	my $length = shift;
	my $array_length = get_array_num_by_ref($ra);
	return sub_array_from_to($ra, $array_length - $length + 1, $array_length);
}
sub mid_array{
	my $ra = shift;
	my $from = shift;
	my $length = shift;
	return sub_array_from_to($ra, $from, $from + $length - 1);
}
sub trim_front{
	my $ra = shift;
	shift @$ra;
}
sub trim_tail{
	my $ra = shift;
	pop @$ra;
}
sub add_front{
	my $ra = shift;
	my $item = shift;
	unshift @$ra, $item;
}
sub add_tail{
	my $ra = shift;
	my $item = shift;
	push @$ra, $item;
}
sub unique_array{
	my $ra = shift;
	my @array;
	foreach(@$ra){
		if(!is_in_array(\@array, $_)){
			push @array, $_;
		}
	}
	return \@array;
}
sub count_in_array{
	my $ra = shift;
	my $item = shift;
	my $count = 0;
	foreach(@$ra){
		if(defined($_) and defined($item) and ($_ eq $item)){
			$count++;
		}
	}
	return $count;
}
sub make_new_array{
	my $ra = shift;
	my @array;
	foreach(@$ra){
		if(ref($_) eq 'ARRAY'){
			push @array, make_new_array($_);
		}elsif(ref($_) eq 'HASH'){
			push @array, make_new_hash($_);
		}else{
			push @array, $_;
		}
	}
	return \@array;
}
sub make_new_hash{
	my $rh = shift;
	my %hash;
	foreach(keys %$rh){
		if(ref($rh->{$_}) eq 'ARRAY'){
			$hash{$_} = make_new_array($rh->{$_});
		}elsif(ref($rh->{$_}) eq 'HASH'){
			$hash{$_} = make_new_hash($rh->{$_});
		}else{
			$hash{$_} = $rh->{$_};
		}
	}
	return \%hash;
}
sub clone{
	my $r = shift;
	if(ref($r) eq 'ARRAY'){
		return make_new_array($r);
	}elsif(ref($r) eq 'HASH'){
		return make_new_hash($r);
	}else{
		return $r;
	}
}
sub add_to_ra_rh{
	my $ra = shift;
	my $key = shift;
	my $value = shift;
	foreach(@$ra){
		$_->{$key} = $value;
	}
	return $ra;
}

sub max{
	my $ra = shift;
	my $max = $ra->[0];
	my $lebgth = get_array_num_by_ref($ra);
	foreach(2..$lebgth){
		if($ra->[$_ -1] > $max){
			$max = $ra->[$_ -1]; 
		}
	}
	return $max;
}
sub max_several{
	my $ra = shift;
	my $num = shift;
	my $lebgth = get_array_num_by_ref($ra);
	if($num >= $lebgth){
		return $ra;
	}
	my @array;
	foreach(1..$num){
		$array[$_ - 1] = $ra->[$_ - 1];
	}
	foreach(($num+1)..$lebgth){
		add_to_max(\@array, $ra->[$_ - 1]);
	}
	return \@array;
}
sub min_several{
	my $ra = shift;
	my $num = shift;
	my $length = get_array_num_by_ref($ra);
	if($num >= $length){
		return $ra;
	}
	my @array;
	foreach(1..$num){
		$array[$_ - 1] = $ra->[$_ - 1];
	}
	foreach(($num+1)..$lebgth){
		add_to_min(\@array, $ra->[$_ - 1]);
	}
	return \@array;
}
sub min{
	my $ra = shift;
	my $min = $ra->[0];
	my $length = get_array_num_by_ref($ra);
	foreach(2..$length){
		if($ra->[$_ -1] < $min){
			$min = $ra->[$_ -1]; 
		}
	}
	return $min;
}
sub add_to_min{
	my $ra = shift;
	my $new = shift;
	if($new >= max($ra)){
		return;
	}
	my $max = $ra->[0];
	$ra->[0] = $new;
	my $lebgth = get_array_num_by_ref($ra);
	foreach(2..$lebgth){
		if($ra->[$_ -1] > $max){
			my $temp = $max;
			$max = $ra->[$_ -1]; 			
			$ra->[$_ -1] = $temp;		
		}
	}
}
sub add_to_max{
	my $ra = shift;
	my $new = shift;
	if($new <= min($ra)){
		return;
	}
	my $min = $ra->[0];
	$ra->[0] = $new;
	my $length = get_array_num_by_ref($ra);
	foreach(2..$length){
		if($ra->[$_ -1] < $min){
			my $temp = $min;
			$min = $ra->[$_ -1]; 			
			$ra->[$_ -1] = $temp;		
		}
	}
}
sub array_and_array{
	my $array1 = shift;
	my $array2 = shift;
	my @new;
	foreach(@$array1){
		if(is_in_array($array2, $_)){
			push @new, $_;
		}
	}
	return \@new;
}
sub array_sub_array{
	my $array1 = shift;
	my $array2 = shift;
	my @new;
	foreach(@$array1){
		if(!is_in_array($array2, $_)){
			push @new, $_;
		}
	}
	return \@new;
}
sub array_add_array{
	my $array1 = shift;
	my $array2 = shift;
	my @new;
	foreach(@$array1){
		push @new, $_;	
	}
	foreach(@$array2){
		if(!is_in_array(\@new, $_)){
			push @new, $_;
		}
	}
	return \@new;
}

#----------------------------------------------
sub print_anything_html{
	print "<p align=left>";
	print "<br>-----------------------------<br>";	
	print_anything_loop_html("",shift,0);
	print "<br>-----------------------------<br>";
	print "</p>";
}
#----------------------------------------------
sub print_anything_loop_html{#($r_, $layer)
	my($head, $r_unknow, $layer)= @_; 
	print_space_html($layer);
	if(defined($head)){
		print $head;
	}
	if(ref($r_unknow) eq 'HASH'){		
		#print "HASH_REF<br>";
		print "<br>";
		$layer++;
		print_space_html($layer);
		print_strong_word('{');
		print '<br>';
		foreach(keys %{$r_unknow}){
			print_anything_loop_html($_.' => ', $r_unknow->{$_} ,$layer);
		}
		print_space_html($layer);
		print_strong_word('}');
		print '<br>';
	}elsif(ref($r_unknow) eq 'ARRAY'){
		#print "ARRAY_REF<br>";
		print "<br>";
		$layer++;
		print_space_html($layer);
		print_strong_word('[');
		print '<br>';
		foreach(@{$r_unknow}){
			print_anything_loop_html('', $_ ,$layer);
		}
		print_space_html($layer);
		print_strong_word(']');
		print '<br>';
	}else{
		if(defined($r_unknow)){
			print "'";
			print_strong_word($r_unknow,'blue',3);
			print "',", "   <br>";
		}else{
			print "undef", ",  <br>";
		}
	}
}

sub print_strong_word{
	my $word = shift || "";
	my $color = shift || "red";
	my $size = shift || 4;
	print "<font color=$color size = $size><strong><b>$word</b></strong></font>";
}
#----------------------------------------------
sub print_space_html{#($count)
	my($count) = @_;
	$count = $count*2;
	while($count-- > 0){
		print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
	}
}

#----------------------------------------------
sub print_anything{
	my ($something) = @_;
	print "\n-----------------------------\n";
	print_anything_loop("",$something,0);
	print "\n-----------------------------\n";
}
#----------------------------------------------
sub print_anything_loop{#($r_, $layer)
	my($head, $r_unknow, $layer)= @_; 
	print_space($layer);
	if(defined($head)){
		print $head;
	}
	if(ref($r_unknow) eq 'HASH'){		
		print "HASH_REF\n";
		$layer++;
		foreach(keys %{$r_unknow}){
			print_anything_loop('|'.$_.'=>', $r_unknow->{$_} ,$layer);
		}
	}elsif(ref($r_unknow) eq 'ARRAY'){
		print "ARRAY_REF\n";
		$layer++;
		foreach(@{$r_unknow}){
			print_anything_loop('|', $_ ,$layer);
		}
	}else{
		if(defined($r_unknow)){
			print $r_unknow, "\n";
		}else{
			print "undef", "\n";
		}
	}
}
#----------------------------------------------
sub print_space{#($count)
	my($count) = @_;
	while($count-- > 0){
		print "            ";
	}
}


#0003
#++++++++++++++++++display area++++++++++++++++++++
#----------------------------------------------
sub set_to_tmpl{
	my ($view, $rh_param) = @_;
	foreach(keys %{$rh_param}){
		$view->tmpl_param($_, $rh_param->{$_});
	}
}
#----------------------------------------------
sub save_to_session{
	my ($view, $rh_param) = @_;
	foreach(keys %{$rh_param}){
		$view->session_param($_=>$rh_param->{$_});
	}
}
#---------------------------------------------
sub get_from_client{
	my $view = shift;
	my $ra_fields = shift;
	my %param;
	foreach(@$ra_fields){
		my @a = $view->qp($_);
		$param{$_} = \@a;		
	}
	return \%param;
}
#---------------------------------------------
sub clear_session{
	my $view = shift;
	my $ra_fields = shift;
	foreach(@$ra_fields){
		if(defined($_)){
			$view->sp($_ => undef);
		}
	}
}
#---------------------------------------------
sub get_from_session{
	my $view = shift;
	my $ra_fields = shift;
	my %param;
	foreach(@$ra_fields){
		$param{$_} = $view->sp($_);
	}
	return \%param;
}
#----------------------------------------------
sub need_map_array{
	my ($rh_map_list, $ra_array) = @_;
	my $item;
	if(ref($ra_array) ne 'ARRAY'){
		$ra_array = make_array($ra_array);
	}
	foreach $item(@{$ra_array}){
#		foreach(keys %$item){
#			$item->{$_} = $rh_map_list->{$_}->{$item->{$_}} if defined($item->{$_});
#		}
		$item->{'province'} = $rh_map_list->{'province'}->{$item->{'province'}} if defined($item->{'province'});
		$item->{'city'} = $rh_map_list->{'city'}->{$item->{'city'}} if defined($item->{'city'});
		$item->{'merchant_type'} = $rh_map_list->{'merchant_type'}->{$item->{'merchant_type'}} if defined($item->{'merchant_type'});
		$item->{'pay_type'} = $rh_map_list->{'pay_type'}->{$item->{'pay_type'}} if defined($item->{'pay_type'});
		$item->{'website_category'} = $rh_map_list->{'website_category'}->{$item->{'website_category'}} if defined($item->{'website_category'});
		$item->{'website_type'} = $rh_map_list->{'website_type'}->{$item->{'website_type'}} if defined($item->{'website_type'});
		$item->{'website_autoapply'} = $rh_map_list->{'website_autoapply'}->{$item->{'website_autoapply'}} if defined($item->{'website_autoapply'});
		$item->{'as_promotion_relation'} = $rh_map_list->{'as_promotion_relation'}->{$item->{'as_promotion_relation'}} if defined($item->{'as_promotion_relation'});
	}	
}
#-------------------------------------------
sub print_image_to_client{
	my ($filename) = @_;
	if(defined($filename)){			
		my $CHUNK_SIZE=4096;  	
		open(MY_FILE,"< $filename") or return 0;
		binmode(MY_FILE); 
		binmode(STDOUT); 
		my $ext = CGIUtility::parser_path($filename)->{'ext'};
		if($ext eq "jpg"){
			$ext = "jpeg";
		}
		print"Content-type:image/".$ext."\r\n"; 
		print"\r\n"; 
		my $data;
		while(my $cb=read(MY_FILE,$data,$CHUNK_SIZE)){ 
			print $data; 
		} 
		close(MY_FILE); 
	}
}
#----------------------------------------------
#0004
#add function here
sub is_int_or_float{
	my $value = shift;
	if(defined($value) and $value =~ m/^\s*\d+\s*$|^\s*\d+\.\d*\s*$/){
		return 1;
	}else{
		return 0;
	}
}

sub print_view_input_info{
	my $view = shift;
	my @result = $view->query_param();
	my %key_value;
	foreach(@result){
		$key_value{$_} = $view->query_param($_);
	}
	my @new_array;
	foreach(sort keys %key_value){
		push @new_array, [$_, $key_value{$_}];
	}
	unshift @new_array, "Input ".1*@new_array;
	print_anything_html(\@new_array);
}

sub print_view_session_info{
	my $view = shift;
	my @result = $view->session_param();
	my %key_value;
	foreach(@result){
		$key_value{$_} = $view->session_param($_);
	}
	my @new_array;
	foreach(sort keys %key_value){
		push @new_array, [$_, $key_value{$_}];
	}
	unshift @new_array, "Session ".1*@new_array;
	print_anything_html(\@new_array);
}


sub get_view_param{
	my $view = shift;
	my @result = $view->qp();
	my %rh_hash;
	foreach(@result){
		$rh_hash{$_} = $view->qp($_);
	}
	return \%rh_hash;
}

sub get_view_session_param{
	my $view = shift;
	my @result = $view->sp();
	my %rh_hash;
	foreach(@result){
		$rh_hash{$_} = $view->sp($_);
	}
	return \%rh_hash;
}

sub sort_and_reverse_array{
	my $view = shift;
	my $ra_list = shift;
	my $sort_type = shift;
	my $sort_key = shift;

	#sort array
	if($sort_type eq 'int'){
		$ra_list = sort_array_hash_int($ra_list, $sort_key);
	}elsif($sort_type eq 'string'){
		$ra_list = sort_array_hash_string($ra_list, $sort_key);
	}

	#see reverse array
	if(defined($view->qp('ctl_reverse'))){
		if($view->sp('reverse_1993688638263')){
			$view->sp('reverse_1993688638263'=>undef);
		}else{
			$view->sp('reverse_1993688638263'=>1);
		}
	}else{
		$view->sp('reverse_1993688638263'=>undef);
		$view->sp('ctl_before_operation_1993688638263'=>undef);
	}

	#see the sort area is same as the before sort area
	unless(is_all_same($sort_key, $view->sp('ctl_before_operation_1993688638263'))){
		$view->sp('ctl_before_operation_1993688638263'=>$sort_key);
		$view->sp('reverse_1993688638263'=>undef);
	}

	#reverse the list when the 'op' in session is 1
	if($view->sp('reverse_1993688638263')){
		$ra_list = reverse_array($ra_list);
	}
	return $ra_list;
}

#CGIUtility::print_cvs("haha.csv", [['zhu','zhu','zhu'],[1,2,3],[1,2,3],[1,2,3],[1,2,3],]);
sub print_csv{
	my $out_file_name = shift;
	my $ra_head = shift;
	my $ra_ra_data = shift;
	unshift @$ra_ra_data, $ra_head if $ra_head;	
	print "Content-disposition: attachment; filename=\"$out_file_name\"\n";
	print "Content-type: application/octet-stream\n\n";
	foreach(@$ra_ra_data){
		print join(',', @$_);
		print "\n";
	}
}

#process page apart and sort reverse
sub process_page_apart_and_sort{
	my $sort_int_key_map = shift;
	my $page_setings = shift;
	my $view = shift;

	my $page_num = ($view->qp('ctl_page_num') || $view->sp('page_num') || 1);
	$view->sp('page_num'=>$page_num);
	my $page_process = new PageApart(
		-current_data=>$page_setings->{'-current_data'},
		-items_per_page => $page_setings->{'-items_per_page'},
		-page_num_before => $page_setings->{'-page_num_before'},
		-page_num_after => $page_setings->{'-page_num_after'},
		-current_page_num => $page_num,
		-total_items_num => $page_setings->{'-total_items_num'},
	);
	my $result = $page_process->get_pagination_result();
	my $temp_list = $result->{'ctl_show_list'};

	my $sort = $page_setings->{'-sort_type_int'}; 
	if($sort && $sort_int_key_map->{$sort}){
		my @key_type = split('/', $sort_int_key_map->{$sort});
		$temp_list = sort_and_reverse_array($view, $temp_list, $key_type[1], $key_type[0]);
	}else{
		$view->sp('reverse_1993688638263'=>undef);
		$view->sp('ctl_before_operation_1993688638263'=>undef);
	}
	$result->{'ctl_show_list'} = $temp_list;
	set_to_tmpl($view, $result);
}

#process page apart and sort reverse
sub process_page_apart_and_sort_all_data{
	my $sort_int_key_map = shift;
	my $page_setings = shift;
	my $view = shift;
	my $page_num = ($view->qp('ctl_page_num') || $view->sp('page_num') || 1);
	$view->sp('page_num'=>$page_num);
	my $page_process = new PageApart(
		-all_data=>$page_setings->{'-all_data'},
		-items_per_page => $page_setings->{'-items_per_page'},
		-page_num_before => $page_setings->{'-page_num_before'},
		-page_num_after => $page_setings->{'-page_num_after'},
		-current_page_num => $page_num,
	);
	my $result = $page_process->get_pagination_result();
	my $temp_list = $result->{'ctl_show_list'};

	my $sort = $page_setings->{'-sort_type_int'}; 
	if($sort && $sort_int_key_map->{$sort}){
		my @key_type = split('/', $sort_int_key_map->{$sort});
		$temp_list = sort_and_reverse_array($view, $temp_list, $key_type[1], $key_type[0]);
	}else{
		$view->sp('reverse_1993688638263'=>undef);
		$view->sp('ctl_before_operation_1993688638263'=>undef);
	}
	$result->{'ctl_show_list'} = $temp_list;
	set_to_tmpl($view, $result);
}

sub add_log{
	my $info = shift;
	my $log_name = shift || 'my.log';
	my $make_new = shift || 0;
	
	my $file_detail = get_file_stat($log_name);
	if($file_detail and ($make_new or ($file_detail->{'file_size'} and $file_detail->{'file_size'} > NEW_FILE_SIZE))){
		rename $log_name, $log_name.'--'.date()->{'string'};
	}

	open FH, ">> $log_name";
	flock FH, 2;
	if (defined FH) {		
		print FH "[";
		my $time = date()->{'string3'};
		print FH $time;
		print FH "] ";
		print FH "[";
		print FH $$;
		print FH "] ";
		print FH dump($info);
		print FH "\n";
		close FH;
	}
}

sub store_into_file{
	my $r_data = shift;
	my $file = shift || 'my.date'; 	
 	open F ,"> $file";
 	flock F, 2;
	binmode F;
	#print F Storable::nfreeze($r_data);
	print F dump($r_data);
	close F;		
}

sub retrive_from_file{
	my $file = shift || 'my.date';
	my $buf;
	unless(-e $file){
		return {};
	}
	open F ,"< $file";
	binmode F;
	read F ,$buf,10000000;
	close F;	
	#return Storable::thaw($buf);
	my $rtn = eval $buf;
	if($@){
		die $@;
	}else{
		return $rtn;
	}
}

sub store_config_file{
	my $r_data = shift;
	my $file = shift || 'my.config';
 	open F ,"> $file";
 	flock F, 2;
	foreach(sort keys %$r_data){
		print F "[$_]\n";
		foreach my $key(sort keys %{$r_data->{$_}}){
			print F "$key=",$r_data->{$_}->{$key},"\n" if $r_data->{$_}->{$key};
		}
		print F "\n";
	}
	close F;		
}

sub retrive_config_file{
	my $file = shift || 'my.config';
	my %config;
	unless(-e $file){
		return {};
	}
	open F ,"< $file";
	my $now_name = "";
	while(<F>){
		next unless $_;
		if($_ =~ m/\[(.*)\]/){
			$now_name = $1;
			next;
		}
		if($_ =~ m/(\w+)\=(.*)/){
			$config{$now_name}->{$1} = $2;
			next;
		}
	}
	close F;	
	return \%config;
}

sub get_file_stat{
	my $file = shift;
	my @attr = stat $file;
	return {
		file_dev_num => $attr[0],
		file_inode_num => $attr[1],
		file_access_option => $attr[2],
		file_hard_link_num =>$attr[3],
		file_owner_id => $attr[4],
		file_group_id => $attr[5],
		file_dev_type => $attr[6],
		file_size => $attr[7],
		file_last_access_time => $attr[8],
		file_last_modify_time => $attr[9],
		inode_last_modify_time => $attr[10],
		file_io_op_block_size => $attr[11],
		file_block_num => $attr[12],
	};
}

sub see_bug{
	return 0;
}

END{
}

1;