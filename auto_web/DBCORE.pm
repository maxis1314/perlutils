package DBCORE;

use DBConnectionMysql;
#eval "use DBConnectionOracle;";
#eval "use DBConnectionAccess;";

#speed
use constant INSERT_ITEM_EVERY_TIME => 2000;
use constant UPDATE_ITEM_EVERY_TIME => 1000;

#sql delete
use constant DELETE_TABLE_DATA => 'delete from ?';

#sql select simple
use constant SELECT_TABLE_DATA => 'select * from ?';

#sql insert
use constant INSERT_TABLE_DATA_ARRAY => 'insert into ? values(?)';
use constant INSERT_TABLE_DATA_HASH => 'insert into ?(?) values(?)';
use constant LARGE_INSERT_TABLE_DATA_ARRAY => 'insert ignore into ? values';
use constant LARGE_INSERT_TABLE_DATA_HASH => 'insert ignore into ?(?) values';

sub new{
	my $class=shift || 0;
	my $rh_connect_param = shift;
	my $db_type = shift || 'Mysql'; 

	my $self = {};
	
	eval '$self->{\'dbcon\'} = new DBConnection'.$db_type.'($rh_connect_param);';
	die $@ if $@;
	
	bless $self,$class;
	return $self;
}

#-----------------------001-----------------------------
#=======EXISTS===============
#001 -- simplely insert ra ra data
sub exists_record{
	my $self = shift;
	my $sql = shift;
	my $ra_exec_param = shift;

	my $ra = $self->get_ra_exec($sql,$ra_exec_param);
	if($ra){
		return 1;
	}
	return 0;	
}

#=======INSERT===============
#001 -- simplely insert ra ra data
sub insert_ra_ra_by_table_name{
	my $self = shift;
	my $table_name= shift;
	my $ra_ra = shift;

	my $element = $ra_ra->[0];
	my $table_width = 1*@$element;
	my @param;
	foreach(1..$table_width){
		push @param, '?';
	}
	my $param_val = join(',', @param);

	my $sql = bind_param(INSERT_TABLE_DATA_ARRAY,[$table_name, $param_val]);
	$self->insert_ra_ra_exec($sql,$ra_ra);
}

#001 -- simplely insert ra rh data
sub insert_ra_rh_by_table_name{
	my $self = shift;
	my $table_name= shift;
	my $ra_rh = shift;

	my $element = $ra_rh->[0];
	my @key;
	my @param;
	foreach(keys %$element){
		push @key,$_;
		push @param, '?';
	}
	my $param_key = join(',', @key);
	my $param_val = join(',', @param);

	my $sql = bind_param(INSERT_TABLE_DATA_HASH,[$table_name, $param_key, $param_val]);
	$self->insert_ra_rh_exec($sql,$ra_rh,\@key);
}

#001 -- simplely insert ra
sub insert_ra_by_table_name{
	my $self = shift;
	my $table_name= shift;
	my $ra = shift;

	my $element = $ra;
	my $table_width = 1*@$element;
	my @param;
	foreach(1..$table_width){
		push @param, '?';
	}
	my $param_val = join(',', @param);

	my $sql = bind_param(INSERT_TABLE_DATA_ARRAY,[$table_name, $param_val]);
	return $self->insert_ra_exec($sql,$ra);
}

#001 -- simplely insert rh
sub insert_rh_by_table_name{
	my $self = shift;
	my $table_name= shift;
	my $rh = shift;

	my $element = $rh;
	my @key;
	my @param;
	foreach(keys %$element){
		push @key,$_;
		push @param, '?';
	}
	my $param_key = join(',', @key);
	my $param_val = join(',', @param);

	my $sql = bind_param(INSERT_TABLE_DATA_HASH,[$table_name, $param_key, $param_val]);
	return $self->insert_rh_exec($sql,$rh,\@key);
}

#=======UPDATE=========
sub update_table_by_table_name{
	my $self = shift;
	my $table_name = shift;
	my $rh = shift;
	my $condition = shift || "";
	
	my @keys = (keys %$rh);
	my @set_fields;
	my @param;
	foreach my $key(@keys){
		push @set_fields, $key."=?";
		push @param, $rh->{$key};
	}
	my $update_string = join(", ",@set_fields);
	if($condition){
		$condition = " where ".$condition;
	}

	return $self->update_exec("update $table_name set ".$update_string.$condition,\@param);
}

sub delete_table_by_table_name{
	my $self = shift;
	my $table_name = shift;
	my $condition = shift || "";
	
	my $update_string = join(", ",@set_fields);
	if($condition){
		$condition = " where ".$condition;
	}

	return $self->update_exec("delete from $table_name ".$condition);
}

#=======GET===============
#001 -- simplely get ra ra
sub get_ra_ra_by_table_name{
	my $self = shift;
	my $table_name = shift;
	my $where_condition = shift;
	my $ra_exec_param = shift;

	my $sql = bind_param(SELECT_TABLE_DATA, [$table_name]);
	$sql.=' where '.$where_condition if $where_condition;

	my $ra = $self->get_ra_ra_exec($sql,$ra_exec_param);
	return $ra;
}
#001 -- simplely get ra
sub get_ra_by_table_name{
	my $self = shift;
	my $table_name = shift;
	my $where_condition = shift;
	my $ra_exec_param = shift;

	my $sql = bind_param(SELECT_TABLE_DATA, [$table_name]);
	$sql.=' where '.$where_condition if $where_condition;

	my $ra = $self->get_ra_exec($sql,$ra_exec_param);
	return $ra;
}
#001 -- simplely get ra
sub get_rh_by_table_name{
	my $self = shift;
	my $table_name = shift || "";
	my $where_condition = shift;
	my $ra_exec_param = shift;

	my $sql = bind_param(SELECT_TABLE_DATA, [$table_name]);
	$sql.=' where '.$where_condition if $where_condition;

	my $rh = $self->get_rh_exec($sql,$ra_exec_param);
	return $rh;
}
#001 -- simplely get ra rh
sub get_ra_rh_by_table_name{
	my $self = shift;
	my $table_name = shift;
	my $where_condition = shift;
	my $ra_exec_param = shift;
	my $tail = shift;

	my $sql = bind_param(SELECT_TABLE_DATA, [$table_name]);
	$sql.=' where '.$where_condition if $where_condition;
	$sql.=' '.$tail if $tail;

	my $ra = $self->get_ra_rh_exec($sql,$ra_exec_param);
	return $ra;
}

#001 =======EMPTY===============
sub empty_table{
	my $self = shift;
	my $ra_table= shift;
	if(ref($ra_table) ne 'ARRAY'){
		$ra_table = [$ra_table];
	}

	foreach(@$ra_table){
		my $sql = bind_param(DELETE_TABLE_DATA, [$_]);
		$self->update_exec($sql);
	}
}
#-----------------------000-----------------------------
#000 -- insert ra ra data every time  INSERT_ITEM_EVERY_TIME
sub large_insert_ra_ra_by_table_name{
	my $self = shift;
	my $table_name= shift;
	my $ra_ra = shift || [[]];
	my $db_re;

	my $dbcon = $self->{'dbcon'};
	my $sth;
	my $element = $ra_ra->[0];
	my $every_time_insert = INSERT_ITEM_EVERY_TIME;
	my $table_width = ($element and ref($element) eq 'ARRAY') ? 1*@$element:0;
	my $count = 0;
	my $sql = bind_param(LARGE_INSERT_TABLE_DATA_ARRAY,[$table_name]);
	my $new_sql;

	my @param;
	foreach(1..$table_width){
		push @param, '?';
	}
	my $param_val = '('.join(',', @param).'),';

	my $every_time_data = [];
	foreach(@$ra_ra){
		$count ++;
		push @$every_time_data, @$_;
		if($count%$every_time_insert == 0){
			$new_sql = $sql.($param_val x $count);
			chop($new_sql);
			$sth = $dbcon->prepare($new_sql);

			$db_re = $dbcon->execute($sth,@$every_time_data);
			$every_time_data = [];
			$count = 0;
		}
	}

	if($count){
		$new_sql = $sql.($param_val x $count);
		chop($new_sql);
		$sth = $dbcon->prepare($new_sql);

		$db_re = $dbcon->execute($sth,@$every_time_data);
	}
}

#000 -- insert ra rh data every time  INSERT_ITEM_EVERY_TIME
sub large_insert_ra_rh_by_table_name{
	my $self = shift;
	my $table_name= shift;
	my $ra_rh = shift || [{}];
	my $db_re;

	my $dbcon = $self->{'dbcon'};
	my $sth;
	my $element = $ra_rh->[0];
	my $every_time_insert = INSERT_ITEM_EVERY_TIME;
	my $count = 0;
	my $new_sql;

	my @param;
	foreach(keys %$element){
		push @key,$_;
		push @param, '?';
	}
	my $param_key = join(',', @key);
	my $param_val = '('.join(',', @param).'),';
	my $sql = bind_param(LARGE_INSERT_TABLE_DATA_HASH,[$table_name, $param_key]);

	my $every_time_data = [];
	foreach(@$ra_rh){
		$count ++;
		foreach my $key(@key){
			push @$every_time_data, $_->{$key};
		}
		if($count%$every_time_insert == 0){
			$new_sql = $sql.($param_val x $count);
			chop($new_sql);
			$sth = $dbcon->prepare($new_sql);

			$db_re = $dbcon->execute($sth,@$every_time_data);
			$every_time_data = [];
			$count = 0;
		}
	}

	if($count){
		$new_sql = $sql.($param_val x $count);
		chop($new_sql);
		$sth = $dbcon->prepare($new_sql);

		$db_re = $dbcon->execute($sth,@$every_time_data);
	}
}

#000 -- update data every time  UPDATE_ITEM_EVERY_TIME
sub large_simple_update{
	my $self = shift;
	my $sql= shift;
	my $ra = shift || [];
	my $db_re;

	my $dbcon = $self->{'dbcon'};
	my $sth;
	my $element = $ra;
	my $every_time_update = UPDATE_ITEM_EVERY_TIME;
	my $table_width = ($element and ref($element) eq 'ARRAY') ? 1*@$element:0;
	my $count = 0;
	my $new_sql;

	my $every_time_data = [];
	foreach(@$ra){
		$count ++;
		push @$every_time_data, $_;
		if($count%$every_time_update == 0){
			my $param = '?,' x $count;
			chop($param);
			$new_sql = bind_param($sql,[$param]);
			$sth = $dbcon->prepare($new_sql);

			$db_re = $dbcon->execute($sth,@$every_time_data);
			$every_time_data = [];
			$count = 0;
		}
	}

	if($count){
		my $param = '?,' x $count;
		chop($param);
		$new_sql = bind_param($sql,[$param]);
		$sth = $dbcon->prepare($new_sql);

		$db_re = $dbcon->execute($sth,@$every_time_data);
	}
	$dbcon->finish($sth);
}

#000 -- exec insert ra
sub insert_ra_exec{
	my $self = shift;
	my $sql = shift;
	my $ra = shift;
	my $db_re;

	my $dbcon = $self->{'dbcon'};
	$sth = $dbcon->prepare($sql);

	$db_re = $dbcon->execute($sth,@$ra);
	$dbcon->finish($sth);
	return $self->get_single_value('select LAST_INSERT_ID()');
}

#000 -- exec insert rh
sub insert_rh_exec{
	my $self = shift;
	my $sql = shift;
	my $rh = shift;
	my $ra_key = shift;
	my $db_re;

	my $dbcon = $self->{'dbcon'};
	$sth = $dbcon->prepare($sql);
	
	my @param;
	foreach my $key(@$ra_key){
		push @param, $rh->{$key};
	}
	$db_re = $dbcon->execute($sth,@param);
	$dbcon->finish($sth);
	return $self->get_single_value('select LAST_INSERT_ID()');
}

#000 -- exec insert ra ra
sub insert_ra_ra_exec{
	my $self = shift;
	my $sql = shift;
	my $ra_ra = shift;
	my $db_re;

	my $dbcon = $self->{'dbcon'};
	$sth = $dbcon->prepare($sql);

	foreach(@$ra_ra){
		$db_re = $dbcon->execute($sth,@$_);
	}
	$dbcon->finish($sth);
}

#000 -- exec insert ra rh
sub insert_ra_rh_exec{
	my $self = shift;
	my $sql = shift;
	my $ra_rh = shift;
	my $ra_key = shift;
	my $db_re;

	my $dbcon = $self->{'dbcon'};
	$sth = $dbcon->prepare($sql);

	foreach(@$ra_rh){
		my @param;
		foreach my $key(@$ra_key){
			push @param, $_->{$key};
		}
		$db_re = $dbcon->execute($sth,@param);
	}
	$dbcon->finish($sth);
}

#000 -- get ra
sub get_ra_exec{
	my $self = shift;
	my $sql = shift;
	my $ra_exec_param = shift || [];
	my $dbcon = $self->{'dbcon'};
	my $db_re;

	$sth = $dbcon->prepare($sql);
	$db_re = $dbcon->execute($sth,@$ra_exec_param);
	
	my $ra = $dbcon->fetchrow_arrayref($sth);
	$dbcon->finish($sth);
	return $ra;
}

#000 -- get rh
sub get_rh_exec{
	my $self = shift;
	my $sql = shift;
	my $ra_exec_param = shift || [];
	my $dbcon = $self->{'dbcon'};
	my $db_re;

	$sth = $dbcon->prepare($sql);

	$db_re = $dbcon->execute($sth,@$ra_exec_param);
	my $rh = $dbcon->fetchrow_hashref($sth);
	$dbcon->finish($sth);
	return $rh;
}


#000 -- get ra ra
sub get_ra_ra_exec{
	my $self = shift;
	my $sql = shift;
	my $ra_exec_param = shift || [];
	my $dbcon = $self->{'dbcon'};
	my $db_re;

	$sth = $dbcon->prepare($sql);

	$db_re = $dbcon->execute($sth,@$ra_exec_param);
	my $ra = $dbcon->fetchall_arrayref($sth);
	$dbcon->finish($sth);
	return $ra;
}

#000 -- get ra rh
sub get_ra_rh_exec{
	my $self = shift;
	my $sql = shift;
	my $ra_exec_param = shift || [];
	my $dbcon = $self->{'dbcon'};
	my $db_re;

	$sth = $dbcon->prepare($sql);

	$db_re = $dbcon->execute($sth,@$ra_exec_param);
	my $ra = $dbcon->fetchall_arrayref($sth,{});
	$dbcon->finish($sth);
	return $ra;
}

#000 -- exec one value
sub get_single_value{
	my $self = shift;
	my $sql = shift;
	my $ra_exec_param = shift || [];
	my $db_re;

	my $dbcon = $self->{'dbcon'};
	my $sth = $dbcon->prepare($sql);

	$db_re = $dbcon->execute($sth,@$ra_exec_param);
	my $result = $dbcon->fetchrow_arrayref($sth);
	$dbcon->finish($sth);
	return $result->[0];
}

#000 -- get single column
sub get_single_col{
	my $self = shift;
	my $sql = shift;
	my $ra_exec_param = shift || [];
	my $dbcon = $self->{'dbcon'};
	my $db_re;
	$db_re = $dbcon->selectcol_arrayref($sql,undef,@$ra_exec_param);
	return $db_re;
}

#000 -- exec sql
sub update_exec{
	my $self = shift;
	my $sql = shift;
	my $ra_exec_param = shift || [];
	my $db_re;

	my $dbcon = $self->{'dbcon'};
	$sth = $dbcon->prepare($sql);

	$db_re = $dbcon->execute($sth,@$ra_exec_param);
	$dbcon->finish($sth);
	return $db_re;
}

#-----------------------other-----------------------------
sub get_database_link_param{
	my $self = shift;
	return $self->{'dbcon'}->{'database_link_param'};	
}

sub get_database_identity{
	my $self = shift;
	return $self->{'dbcon'}->{'database'};
}

sub get_time{
	my $self = shift;
	my $dbcore = $self->{'dbcore'};
	my $time_int =  $dbcore->get_single_value('select UNIX_TIMESTAMP()');
	my $time_string =  $dbcore->get_single_value('select CURRENT_TIMESTAMP()');
	return {time_int=>$time_int,time_str=>$time_string};
}

sub get_tables{
	my $self = shift;
	my $dbcon = $self->{'dbcon'};
	my @names = $dbcon->tables();
	foreach(@names){
		$_ =~ s/`//g;
	}
	return \@names;
}

sub get_create_table_exec_string{
	my $self = shift;
	my $dbcon = $self->{'dbcon'};
	my $table_name = shift;

	return $dbcon->get_create_table_exec_string($table_name);
}

sub get_database_character_set_exec_string{
	my $self = shift;
	my $dbcon = $self->{'dbcon'};

	return $dbcon->get_database_character_set_exec_string();
}

sub get_to_insert_id_by_table_name{
	my $self = shift;
	my $table_name = shift;
	return $self->insert_ra_by_table_name('db_id',[undef,$table_name]);
}

sub quote_string{
	my $self = shift;
	my $string = shift;
	my $dbcon = $self->{'dbcon'};
	return $dbcon->quote($string);
}

sub get_dbh{
	my $self = shift;
	my $string = shift;
	return $self->{'dbcon'}->get_dbh();
}

sub get_dbcore{
	my $self = shift;
	return $self;
}

sub bind_param{
	my $sql = shift;
	my $ra_param = shift;
	foreach(@$ra_param){
		$sql =~ s/\?/$_/;
	}
	return $sql;
}

DESTROY{
	my $self = shift;
	my $dbcon = $self->{'dbcon'};
	if($dbcon){
		$dbcon->disconnect();
	}
}

1;