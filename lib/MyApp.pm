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

my @routes = ("", "About", "CV", "Publications");
foreach (@routes) { get '/' . $_ => route_callback($_, NAVIGATION); }

true;
