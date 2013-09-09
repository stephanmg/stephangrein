# myapp
package MyApp;
use Template;
use Dancer ':syntax';
use Dancer::Plugin::SiteMap;
use Dancer::Plugin::DirectoryView;
use Dancer::Plugin::Auth::Htpasswd;
set layout => 'new_main'; # set main layout

our $VERSION = '0.1';

use constant NAVIGATION => 
    qq(<ul class="box">
    <li><a href="/">Home</a></li> 
    <li><a href="/About">About</a></li>
    <li><a href="/Research">Research Statement</a></li>
    <li><a href="/CV">Curriculum Vitae</a></li>
    <li><a href="/Publications">Publications</a></li>
    <li><a href="/pub/">Downloads</a></li>
    <li><a href="/Imprint">Imprint</a></li>
    </ul>);

get '/' => sub {
    my $route = "";
    my $TEMP = NAVIGATION;
    $TEMP =~ s!<li>(<a href="/$route">.*?</li>)!<li id="nav-active">$1!;

    template 'new_index' => {
        navigation => $TEMP,
        name_of_page => ": $route content"
    };
};

sub callback {
        my $route = shift;
        my $temp = shift;
    return sub {
        $temp =~ s!<li>(<a href="/$route">.*?</li>)!<li id="nav-active">$1!;
        
        template "$route" => {
            navigation => $temp,
            name_of_page => ": $route content content"
        };
    };
}

get '/About' => callback("About", NAVIGATION);
get '/CV' => callback("CV", NAVIGATION);

get '/About' => sub {
    my $route = "About";
    my $TEMP = NAVIGATION;
    $TEMP =~ s!<li>(<a href="/$route">.*?</li>)!<li id="nav-active">$1!;

    template "About" => {
        navigation => $TEMP,
        name_of_page => ": $route content"
    };
};

get '/CV' => sub {
    template 'cv' => {
    navigation => 
    qq(<ul class="box">
    <li><a href="/">Home</a></li> <!-- Active page (highlighted) -->
    <li><a href="/About">About</a></li>
    <li><a href="/Research">Research Statement</a></li>
    <li id="nav-active"><a href="/CV">Curriculum Vitae</a></li>
    <li><a href="/Publications">Publications</a></li>
    <li><a href="/pub/">Downloads</a></li>
    <li><a href="/Imprint">Imprint</a></li>
    </ul>) 
, name_of_page => "!!! cv content!!!"};
};

get '/Publications' => sub {
    template 'publications' => {
    navigation => 
    qq(<ul class="box">
    <li><a href="/">Home</a></li> <!-- Active page (highlighted) -->
    <li><a href="/About">About</a></li>
    <li><a href="/Research">Research Statement</a></li>
    <li><a href="/CV">Curriculum Vitae</a></li>
    <li id="nav-active"><a href="/Publications">Publications</a></li>
    <li><a href="/pub/">Downloads</a></li>
    <li><a href="/Imprint">Imprint</a></li>
    </ul>) 
, name_of_page => "!!! Publications content!!!"};
};

get '/sitemap' => sub {
    template 'about' => {
   name_of_page => "!!! sitemap!!!"};
};
true;
