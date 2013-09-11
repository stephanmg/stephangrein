########################### 
### www stephangrein de ###
###########################
package MyApp;
use Template;
use Dancer ':syntax';
use Dancer::Plugin::SiteMap;
use Dancer::Plugin::DirectoryView;
use Dancer::Plugin::Auth::Htpasswd;
set layout => 'new_main'; # set main layout
our $VERSION = '0.1';
use DBI;
use File::Slurp;
use Crypt::SaltedHash;
use POSIX;

################
### settings ###
################
set 'session' => 'Simple';
set 'database' => './lib/test.db';
set 'username' => 'admin';
set 'password' => 'password';
set 'template' => 'template_toolkit';
set 'emoticons' => '/lib/emoticons';
#set 'logger' => 'console';
#set 'log' => 'debug';
#set 'show_errors' => 1;
#set 'access_log' => 1;
#set 'warnings' => 1;


#########################
### navigation string ###
#########################
use constant NAVIGATION => 
    qq(<ul class="box">
    <li><a href="/">Home</a></li> 
    <li><a href="/About">About</a></li>
    <li><a href="/Research">Research Statement</a></li>
    <li><a href="/CV">Curriculum Vitae</a></li>
    <li><a href="/Publications">Publications</a></li>
    <li><a href="/pub/">Downloads</a></li>
    <li><a href="/Imprint">Imprint</a></li>
    <li><a href="/Blog">Blog</a></li>
    </ul>);

my $flash;

sub set_flash {
	my $message = shift;

	$flash = $message;
}

sub get_flash {

	my $msg = $flash;
	$flash = "";

	return $msg;
}

sub connect_db {
	my $dbh = DBI->connect("dbi:SQLite:dbname=".setting('database')) or
		die $DBI::errstr;

	return $dbh;
}

sub init_db {
	my $db = connect_db();
	my $schema = read_file('./lib/schema.sql');
	$db->do($schema) or die $db->errstr;
}

#hook 'before' => sub {
before_template sub {
	my $tokens = shift;
	
	#$tokens->{'css_url'} = request->base . 'css/style.css';
	$tokens->{'login_url'} = uri_for('/Blog/login');
	$tokens->{'logout_url'} = uri_for('/Blog/logout');
};

get '/Blog' => sub {
	my $db = connect_db();
	my $sql = 'select id, title, text, author, datum from entries order by id desc';
	my $sth = $db->prepare($sql) or die $db->errstr;
	$sth->execute or die $sth->errstr;
    
    my $temp = NAVIGATION;
   $temp =~ s!<li>(<a href="/Blog">.*?</li>)!<li id="nav-active">$1!;

	template 'show_entries.tt' => { 
		'msg' => get_flash(),
		'add_entry_url' => uri_for('/Blog/add'),
    'edit_url' => uri_for('/Blog/edit'),
    'delete_url' => uri_for('/Blog/delete'),
		'entries' => $sth->fetchall_hashref('id'),
    'navigation' => $temp
	};
};

any ['post', 'get'] => '/Blog/delete/*' => sub {
    my $err;
   my ($id) = splat;
    if (not session('user')) {
        send_error("Not logged in", 401);
    }   

    	if ( request->method() eq "GET" ) {
        template 'delete.tt' => {
            delete_url => uri_for('/Blog/delete'),
            entry_id => $id
        };
    } else {
        my $dbh = connect_db();
        my $sql = 'delete from entries where id = ?';
        my $sth = $dbh->prepare($sql) or die $dbh->errstr;
        $sth->execute($id);
        set_flash("Deleted successfully entry no. " . $id);
        redirect '/Blog';
    }
};

any ['get', 'post'] => '/Blog/edit/*' => sub {
	my $err;
  my ($id) = splat; # get wildcard id
    if (not session('user')) {
        send_error("Not logged in", 401);
    }   

    	if ( request->method() eq "GET" ) {
        my $dbh = connect_db();
        my $sql = 'select text from entries where id = ?';
        my $sth = $dbh->prepare($sql) or die $dbh->errstr;

        $sth->execute($id);
		    my $pretext = ($sth->fetchrow_hashref)->{'text'};
        $pretext =~ s!<img src="/images/emoticons/happy\.jpg" alt="happy"/>!:\)!g;
        $pretext =~ s!<img src="/images/emoticons/sad\.jpg" alt="sad"/>!:\(!g;
        
        template 'edit.tt' => {
            edit_url => uri_for('/Blog/edit'),
            entry_id => $id,
            old_text => $pretext
        };
    } else {
        my $dbh = connect_db();
        my $sql = 'update entries set text=? where id = ?';
        my $sth = $dbh->prepare($sql) or die $dbh->errstr;

        my $pretext = params->{'text'};
        $pretext =~ s!:\)!<img src="/images/emoticons/happy\.jpg" alt="happy"/>!g;
        $pretext =~ s!:\(!<img src="/images/emoticons/sad\.jpg" alt="sad"/>!g;
        $sth->execute($pretext, $id);
        if (params->{'titel'} ne "") {
            $sql = 'update entries set title=? where id = ?';
            $sth = $dbh->prepare($sql) or die $dbh->errstr;
            $sth->execute(params->{'titel'}, $id);
        }
        $sql = 'update entries set datum=? where id = ?';
        $sth = $dbh->prepare($sql) or die $dbh->errstr;
        $sth->execute(localtime . "(last update by: " . session('user') . ")", $id);

        set_flash("Entry No. " . $id . " successfully edited");
        redirect '/Blog';
    }
};

post '/Blog/add' => sub {
	if ( not session('user') ) {
		send_error("Not logged in", 401);
	}

	my $db = connect_db();
	my $sql = 'insert into entries (title, text, author, datum) values (?, ?, ?, ?)';
	my $sth = $db->prepare($sql) or die $db->errstr;
  my $now = localtime;

    my $pretext = params->{'text'};
    $pretext =~ s!:\)!<img src="/images/emoticons/happy\.jpg" alt="happy"/>!g;
    $pretext =~ s!:\(!<img src="/images/emoticons/sad\.jpg" alt="sad"/>!g;
	#$sth->execute(params->{'title'}, params->{'text'}) or die $sth->errstr;
	$sth->execute(params->{'title'}, $pretext, session('user'), $now) or die $sth->errstr;


set_flash('New entry posted!');
	redirect '/Blog';
};

any ['get', 'post'] => '/Blog/login' => sub {
	my $err;
	my $dbh = DBI->connect("dbi:SQLite:dbname=./auth.sql") or
		die $DBI::errstr;

	if ( request->method() eq "POST" ) {
    my $sth;
    $sth  = $dbh->prepare("SELECT user FROM users WHERE user = ?");
    my $user = "";
    my $pass = "";
    my $res = "";
    $sth->execute(params->{username}) or die $sth->errstr;
    $res = $sth->fetchrow_hashref();
    $user = $res->{user};

    $sth = $dbh->prepare("SELECT pass FROM users WHERE user = ?");
    $sth->execute(params->{username}) or die $sth->errstr;
    $res = $sth->fetchrow_hashref();
    $pass = $res->{pass};
    if (!$user) {
        set_flash("Invalid user name: " . params->{username});
        redirect '/Blog';
    } else {
        my $csh = Crypt::SaltedHash->new(algorithm => 'SHA-1');
        $csh->add(params->{password});
        if (Crypt::SaltedHash->validate($pass, params->{password})) {
    session 'user' => params->{username};
    set_flash("You are logged in (" . session('user') . ")");
    redirect '/Blog';
    }    else {
    set_flash("Invalid pass word: " . $pass);
    redirect '/Blog';
    session 'user' => false;
    }
    }
}

   my $temp = NAVIGATION;
   $temp =~ s!<li>(<a href="/Blog/login">.*?</li>)!<li id="nav-active">$1!;

	# display login form
	template 'login.tt' => { 
		'err' => $err,
    'navigation' => $temp
    }, 
    {
    layout => "new_main"
    };

};

get '/Blog/logout' => sub {
	session->destroy;
	set_flash('You are logged out.');
	redirect '/Blog';
};

### check for login status otherwise show login form
#get '/Blog/manage' => sub {
#    template 'manage.tt' => {
#    }
#};

init_db();

######################
### handle a route ###
######################
sub route_callback {
    my $route = shift;
    my $template = $route;
    my $temp = shift;
    
    return sub {
        $template = "Home" if $route eq "";
        $temp =~ s!<li>(<a href="/$route">.*?</li>)!<li id="nav-active">$1!;
         
        template $template => {
            navigation => $temp,
            name_of_page => ": $route content content"
        };
    };
}
######################################################
### extract routes from navigation and handle them ###
######################################################
my @routes = grep { $_ ne "Blog" } NAVIGATION =~ m!<li><a href="/(.*?)">.*?</li>!g;
get '/' . $_ => route_callback($_, NAVIGATION) for @routes;

true;
