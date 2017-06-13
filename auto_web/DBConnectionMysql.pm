package DBConnectionMysql;

use DBI;



#connect
use constant HOST => 'localhost';
use constant DATABASE => 'search';
use constant PORT => '3306';
use constant USER => 'root';
use constant PASSWORD => '';

sub new{
	my $class=shift;
	my $rh_connect_param = shift;

	my $host = $rh_connect_param->{'host'} || HOST;
	my $database = $rh_connect_param->{'database'} || DATABASE;
	my $port = $rh_connect_param->{'port'} || PORT;
	my $user = $rh_connect_param->{'user'} || USER;
	my $password = $rh_connect_param->{'password'} || PASSWORD;

	my $self;
	my %attr = (
		PrintError => 0,						# don't report errors via warn()
		RaiseError => 1,	# don't report errors via die()
		FetchHashKeyName=>'NAME_lc',
		AutoCommit=>1
	);
	my $dbh = DBI->connect('DBI:mysql:host='.$host.';database='.$database.';port='.$port, $user, $password, \%attr);
	if(!$dbh){
		die $DBI::errstr;
	}
	$dbh->do("SET NAMES '".$rh_connect_param->{'set_names'}."';") if $rh_connect_param->{'set_names'};
	$self->{'dbh'} = $dbh;
	$self->{'database'} = $host.':'.$port.':'.$database;
	$self->{'database_link_param'} = [$host,$database,$port,$user,$password];
	bless $self,$class;
	return $self;
}


sub prepare{
	my $self = shift;
	my $sql = shift;
	$self->{'pre_sql'} = $sql || "";
	my $dbh = $self->{'dbh'};
	my $sth = $dbh->prepare($sql);
	if(!$sth){
		$self->warn_data({'sql'=>$sql});		
	}
	return $sth;
}

sub execute{
	my $self = shift;
	my $sth = shift;
	my $re;
	eval{
		$re = $sth->execute(@_);
	};
	if($@ || !$re){
		$self->warn_data({'sql'=>$self->{'pre_sql'},'data'=>\@_});
	}
	return $re;
}

sub finish{
	my $self = shift;
	my $sth = shift;
	return $sth->finish();
}

sub fetchrow_arrayref{
	my $self = shift;
	my $sth = shift;
	return $sth->fetchrow_arrayref();
}

sub fetchrow_hashref{
	my $self = shift;
	my $sth = shift;
	return $sth->fetchrow_hashref();
}

sub fetchall_arrayref{
	my $self = shift;
	my $sth = shift;
	return $sth->fetchall_arrayref(@_);
}

sub selectcol_arrayref{
	my $self = shift;
	my $dbh = $self->{'dbh'};
	my $re;
	eval{
		$re = $dbh->selectcol_arrayref(@_);
	};
	if($@ || !$re){
		$self->warn_data({'data'=>\@_});
	}
	return $re;
}

sub errstr{
	my $self = shift;
	my $dbh = $self->{'dbh'};
	return $dbh->errstr;
}

#-----------------------other-----------------------------
sub get_database_link_param{
	my $self = shift;
	return $self->{'database_link_param'};	
}

sub get_database_identity{
	my $self = shift;
	return $self->{'database'};
}

#quote string
sub quote_string{
	my $self = shift;
	my $string = shift;
	my $dbh = $self->{'dbh'};
	return $dbh->quote($string);
}

sub get_dbh{
	my $self = shift;
	my $string = shift;
	return $self->{'dbh'};
}

sub disconnect{
	my $self = shift;
	my $dbh = $self->{'dbh'};
	if($dbh){
		$dbh->disconnect();
		undef $self->{'dbh'};
	}
}

sub tables{
	my $self = shift;
	my $dbh = $self->{'dbh'};
	return $dbh->tables;
}

sub get_create_table_exec_string{
	my $self = shift;
	my $dbh = $self->{'dbh'};
	my $table_name = shift;
	
	my $sql = 'show create table '.$table_name;
	my $sth = $self->prepare($sql);
	$self->execute($sth);
	my $rh_table = $self->fetchrow_hashref($sth,{});

	return $rh_table->{'create table'};
}

sub get_database_character_set_exec_string{
	my $self = shift;
	my $dbh = $self->{'dbh'};
	my @databse = split(':',$self->{'database'});
	
	my $db_name = $databse[2];
	my $sql = 'show create database '.$db_name;
	my $sth = $self->prepare($sql);
	$self->execute($sth);
	my $rh_table = $self->fetchrow_hashref($sth,{});
	$rh_table->{'create database'} =~ s/CREATE/ALTER/ig;

	return $rh_table->{'create database'};
}

sub quote{
	my $self = shift;
	my $string = shift;
	my $dbh = $self->{'dbh'};
	return $dbh->quote($string);
}

sub warn_data{
	my $self = shift;
	my $rh = shift;
	my $dbh = $self->{'dbh'};
	my @call;
	push @call, (@{[caller(5)]})[3];
	push @call, (@{[caller(4)]})[3];
	push @call, (@{[caller(3)]})[3];
	push @call, (@{[caller(2)]})[3];
	push @call, (@{[caller(1)]})[3];
	my $error = $dbh->errstr;
	my $info = {'0_INFO'=>$rh,'1_ERR'=>$error,'2_CALL'=>\@call};
	die $error;
}

DESTROY{
	my $self = shift;
	my $dbh = $self->{'dbh'};
	if($dbh){
		$dbh->disconnect();
		undef $self->{'dbh'};
	}
}

1;