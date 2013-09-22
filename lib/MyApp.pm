#
#===============================================================================
#
#         FILE: MyApp.pm
#
#  DESCRIPTION: Module for dynamics webpage www stephangrein de
#
#        FILES: ---
#         BUGS: ---
#        NOTES: for TODOS see TODOS textfile in parent directory
#       AUTHOR: stephan (stephan@syntaktischer-zucker.de)
# ORGANIZATION: private
#      VERSION: 0.1
#     REVISION: see git log
#===============================================================================
#
# header {{{
## {{{ package's name 
package MyApp;
## }}}

## {{{ modules 
use Template;
use Dancer ':syntax';
use Dancer::Plugin::SiteMap;
use Dancer::Plugin::DirectoryView;
use Dancer::Plugin::Auth::Htpasswd;
use DBI;
use File::Slurp;
use Crypt::SaltedHash;
use POSIX;
use GD::SecurityImage;
use MIME::Base64;
use Exporter;
## }}}

## {{{ exports
our @ISA = qw(Exporter);
our @EXPORT = qw($EMOTICONS_DIR %EMOTICONS emoticonize unemoticonize);
## }}}

## {{{ settings 
our $VERSION = '0.1';
set layout => 'new_main';
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
## }}}
# }}}

# emoticons {{{
## {{{ images 
our $EMOTICONS_DIR = '/images/emoticons';
our %EMOTICONS = (
    ':\)'   => qq!<img src="$EMOTICONS_DIR/happy\.jpg" alt="happy"/>!,
    ':\('  => qq!<img src="$EMOTICONS_DIR/sad\.jpg" alt="sad"/>!,
    ':P'   => qq!<img src="$EMOTICONS_DIR/tongue\.jpg" alt="tongue"/>!
);
## }}}

## {{{ emoticionize 
sub emoticonize {
    my $text = shift; # the plain text string containing smileys
    my $emoticons = shift;

    for my $key (keys %$emoticons) {
        my $val = $emoticons->{$key};
        $text =~ s!$key!$val!g;
    }
   return $text;
}
## }}}

## {{{ unemoticonize 
sub unemoticonize {
    my $text = shift; # the string with encoded smileys as images
    my $emoticons = shift;

    for my $key (keys %$emoticons) {
        my $val = $emoticons->{$key};
        $text =~ s!$val!$key!g;
    }
    
    return $text;   
}
## }}}
# }}}

# navigation string {{{
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
# }}}

# main page {{{
## {{{ flash message 
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
## }}}

## {{{ database handling 
sub connect_db {
	my $dbh = DBI->connect("dbi:SQLite:dbname=".setting('database')) or
		die $DBI::errstr;

	return $dbh;
}

sub init_db {
	my $db = connect_db();
	my $schema = read_file('./lib/schema.sql');
	$db->do($schema) or die $db->errstr;
  $schema = read_file('./lib/schema2.sql');
	$db->do($schema) or die $db->errstr;
}

## }}}

## {{{ hooks 
#hook 'before' => sub {
before_template sub {
	my $tokens = shift;
	
	#$tokens->{'css_url'} = request->base . 'css/style.css';
	$tokens->{'login_url'} = uri_for('/Blog/login');
	$tokens->{'logout_url'} = uri_for('/Blog/logout');
};
## }}}

## {{{ routes 
## {{{ '/Blog' 
get '/Blog' => sub {
	my $db = connect_db();
	my $sql = 'select id, title, text, author, datum from entries order by id desc';
	my $sth = $db->prepare($sql) or die $db->errstr;
	$sth->execute or die $sth->errstr;
    
    my $temp = NAVIGATION;
   $temp =~ s!<li>(<a href="/Blog">.*?</li>)!<li id="nav-active">$1!;

    my $entries = $sth->fetchall_hashref('id');

    $sql = 'select id, text, author, title, article_id from comments';
    $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute or die $sth->errstr;

    my $comments = $sth->fetchall_hashref('id');
    # then use entries.comments
	template 'show_entries.tt' => { 
		'msg' => get_flash(),
		'add_entry_url' => uri_for('/Blog/add'),
    'edit_url' => uri_for('/Blog/edit'),
    'delete_url' => uri_for('/Blog/delete'),
    'comment_url' => uri_for('/Blog/comment'),
    'edit_comment_url' => uri_for('/Blog/edit_comment'),
    'delete_comment_url' => uri_for('/Blog/delete_comment'),
    'entries' => $entries,
    'comments' => $comments,
	#	'entries' => $sth->fetchall_hashref('id'),
    'navigation' => $temp,
    'emoticons' => \%EMOTICONS
	};
};
### }}}

## {{{ '/Blog/delete_comment/*' 
any ['post', 'get'] => '/Blog/delete_comment/*' => sub {
    my $err;
    my ($id) = splat;
    if (not session('user')) {
        send_error("Not logged in", 401);
    }   

    	if ( request->method() eq "GET" ) {
        my $dbh = connect_db();
        my $sql = 'select author, title, text from comments where id = ?';
        my $sth = $dbh->prepare($sql) or die $dbh->errstr;
        $sth->execute($id);

        my $result = ($sth->fetchrow_hashref);
        my $author = $result->{'author'};
        my $title = $result->{'title'};
        my $pretext = $result->{'text'};
        $pretext =~ s!<img src="/images/emoticons/happy\.jpg" alt="happy"/>!:\)!g;
        $pretext =~ s!<img src="/images/emoticons/sad\.jpg" alt="sad"/>!:\(!g;
        my $text = $pretext;

        template 'delete_comment.tt' => {
            delete_comment_url => uri_for('/Blog/delete_comment'),
            entry_id => $id,
            entry_author => $author,
            entry_title => $title,
            entry_text => $text
        };
    } else {
        my $dbh = connect_db();
        my $sql = 'select author, article_id from comments where id = ?';
        my $sth = $dbh->prepare($sql) or die $dbh->errstr;
        $sth->execute($id);
        my $results = $sth->fetchrow_hashref;
        my $author = $results->{'author'};
        my $article_id = $results->{'article_id'};
        if ($author ne session('user')) {
            set_flash("Can only deleted own comments! Comment no. " . $id . " is not your comment for entry no. " . $article_id . ". Refused.");
            redirect '/Blog';
        } else {
            $sql = 'delete from comments where id = ?';
            $sth = $dbh->prepare($sql) or die $dbh->errstr;
            $sth->execute($id);
            set_flash("Deleted successfully comment no. " . $id);
            redirect '/Blog';
     }
    }
};
### }}}

## {{{ '/Blog/edit_comment/*' 
any ['get', 'post'] => '/Blog/edit_comment/*' => sub {
	my $err;
  my ($id) = splat; # get wildcard id
    if (not session('user')) {
        send_error("Not logged in", 401);
    }   

    	if ( request->method() eq "GET" ) {
        my $dbh = connect_db();
        my $sql = 'select text from comments where id = ?';
        my $sth = $dbh->prepare($sql) or die $dbh->errstr;

        $sth->execute($id);
		    my $pretext = ($sth->fetchrow_hashref)->{'text'};
        $pretext =~ s!<img src="/images/emoticons/happy\.jpg" alt="happy"/>!:\)!g;
        $pretext =~ s!<img src="/images/emoticons/sad\.jpg" alt="sad"/>!:\(!g;
        
        template 'edit_comment.tt' => {
            edit_comment_url => uri_for('/Blog/edit_comment'),
            entry_id => $id,
            old_text => $pretext
        };
    } else {
        my $dbh = connect_db();
        my $sql = 'select author from comments where id = ?';
        my $sth = $dbh->prepare($sql) or die $dbh->errstr;
        $sth->execute($id);
        
        my $author = ($sth->fetchrow_hashref)->{'author'};
        if ($author ne session('user')) {
            set_flash("Can only edit own comments. Comment No. " . $id . " is not your own comment. Refused.");
            redirect '/Blog';
        } else {
            $sql = 'update comments set text=? where id = ?';
            $sth = $dbh->prepare($sql) or die $dbh->errstr;
            my $pretext = params->{'text'};
            $pretext =~ s!:\)!<img src="/images/emoticons/happy\.jpg" alt="happy"/>!g;
            $pretext =~ s!:\(!<img src="/images/emoticons/sad\.jpg" alt="sad"/>!g;
            $sth->execute($pretext, $id);
            if (params->{'titel'} ne "") {
                $sql = 'update comments set title=? where id = ?';
                $sth = $dbh->prepare($sql) or die $dbh->errstr;
                $sth->execute(params->{'titel'}, $id);
            }
            set_flash("Comment No. " . $id . " successfully edited.");
            redirect '/Blog';
        }
    }
};
### }}}

## {{{ '/Blog/comment/*' 
any ['post', 'get'] => '/Blog/comment/*' => sub {
    my $err;
    my ($id) = splat;
    # maybe we allow anonymous comments here in future?
    if (not session('user')) {
        send_error("Not logged in", 401);
    }   

   	if ( request->method() eq "GET" ) {
        template 'comment.tt' => {
            comment_url => uri_for('/Blog/comment'),
            entry_id => $id
        };
    } else {
        my $dbh = connect_db();
        my $sql = 'insert into comments (title, text, author, article_id) values (?, ?, ?, ?)';
        my $sth = $dbh->prepare($sql) or die $dbh->errstr;
        

		    my $pretext = params->{'text'};
        $pretext =~ s!:\)!<img src="/images/emoticons/happy\.jpg" alt="happy"/>!g;
        $pretext =~ s!:\(!<img src="/images/emoticons/sad\.jpg" alt="sad"/>!g;
        my $text = $pretext;
        my $author = session('user'); # params->{'author'};
        my $title = params->{'titel'};
        if ($author ne "" && $text ne "" && $title ne "") {
            $sth->execute($title, $text, $author, $id);
            set_flash("Added comment for entry no. " . $id);
            redirect '/Blog';
         } else {

        set_flash("Missing text or title. Refusing adding comment for entry no. " . $id);
        redirect '/Blog';
    }
}
};
### }}}

## {{{ '/Blog/delete/*' 
any ['post', 'get'] => '/Blog/delete/*' => sub {
    my $err;
   my ($id) = splat;
    if (not session('user')) {
        send_error("Not logged in", 401);
    }   

    	if ( request->method() eq "GET" ) {
        my $dbh = connect_db();
        my $sql = 'select author, title, text from entries where id = ?';
        my $sth = $dbh->prepare($sql) or die $dbh->errstr;
        $sth->execute($id);

        my $result = ($sth->fetchrow_hashref);
        my $author = $result->{'author'};
        my $title = $result->{'title'};
        my $pretext = $result->{'text'};
        $pretext =~ s!<img src="/images/emoticons/happy\.jpg" alt="happy"/>!:\)!g;
        $pretext =~ s!<img src="/images/emoticons/sad\.jpg" alt="sad"/>!:\(!g;
        my $text = $pretext;

        template 'delete.tt' => {
            delete_url => uri_for('/Blog/delete'),
            entry_id => $id,
            entry_title => $title,
            entry_author => $author,
            entry_text => $text
        };
    } else {
        my $dbh = connect_db();
        my $sql = 'select author from entries where id = ?';
        my $sth = $dbh->prepare($sql) or die $dbh->errstr;
        $sth->execute($id);
		    my $author = ($sth->fetchrow_hashref)->{'author'};
        if ($author ne session('user')) {
            set_flash("Can only deleted own entries! Entry no. " . $id . " is not your entry. Refused.");
            redirect '/Blog';
        } else {
            $sql = 'delete from entries where id = ?';
            $sth = $dbh->prepare($sql) or die $dbh->errstr;
            $sth->execute($id);

            $sql = 'delete from comments where article_id = ?';
            $sth = $dbh->prepare($sql) or die $dbh->errstr;
            $sth->execute($id);
            set_flash("Deleted successfully entry no. " . $id);
            redirect '/Blog';
        }
    }
};
### }}}

## {{{ '/Blog/edit/*' 
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
### }}}

## {{{ '/Blog/add' 
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
### }}}

## {{{ '/Blog/login' 
any ['get', 'post'] => '/Blog/login' => sub {
	my $err;
	my $dbh = DBI->connect("dbi:SQLite:dbname=./auth.sql") or
		die $DBI::errstr;
	if ( request->method() eq "POST" ) {

    my $captcha_str2 = params->{captcha_str2};
    if (!$captcha_str2 || $captcha_str2 ne session('captcha_str')) {
        redirect '/Blog';
        set_flash("Captcha empty or wrong.");
    } else {
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
    set_flash("Invalid pass word: " . params->{password});
    redirect '/Blog';
    session 'user' => false;
    }
    }
}
}

   my $temp = NAVIGATION;
   $temp =~ s!<li>(<a href="/Blog/login">.*?</li>)!<li id="nav-active">$1!;
    
    generate_capture();
    my $captcha_data = session('captcha_data'); 
    my $captcha_mime = session('captcha_mime');

	# display login form
	template 'login.tt' => { 
		'err' => $err,
    'navigation' => $temp,
    'captcha_mime' => $captcha_mime,
    'captcha_data' => $captcha_data
    }, 
    {
    layout => "new_main"
    };
};
### }}}

## {{{ '/Blog/logout' 
get '/Blog/logout' => sub {
 destroy_captcha();
	session->destroy;
	set_flash('You are logged out.');
	redirect '/Blog';
};
### }}}
## }}}

## {{{ generic route handler 
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
## }}}

## {{{ handle routes from navigation string 
my @routes = grep { $_ ne "Blog" } NAVIGATION =~ m!<li><a href="/(.*?)">.*?</li>!g;
get '/' . $_ => route_callback($_, NAVIGATION) for @routes;
## }}}
# }}}

# captcha {{{
## {{{ security pass 
sub random_pass {
    my $length = shift;
    my $captcha;
    for (1..$length) {
        $captcha .= chr(rand(94)+33);
    }
    return $captcha;
}
## }}}

## {{{ generate 
sub generate_capture {
   my $captcha = random_pass(9);
   my ($data, $mime, $rnd) = GD::SecurityImage->new(
    width => 100,
    height => 60,
    lines => 4,
    thickness => 1,
    gd_font => 'Giant',
    ptsize => 160,
    color => '#02AAFC'
    )
    ->random($captcha)
    ->create(qw/normal circle #02AAFC #02AAFC/)
    ->particle(400)
    ->out;
    
    # base64 encode image here
    my $encoded = MIME::Base64::encode_base64($data);

    session 'captcha_str' => $rnd;
    session 'captcha_data' => $encoded;
    session 'captcha_mime' => $mime;
};
## }}}

## {{{ destroy 
sub destroy_captcha {
    session 'captcha_str' => undef;
    session 'captcha_data' => undef;
    session 'captcha_mime' => undef;
};
## }}}
# }}}

# initializer {{{
init_db();
true;
# }}}
