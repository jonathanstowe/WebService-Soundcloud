#!perl6

use v6;
use lib 'lib';
use Test;



use WebService::Soundcloud;

my $username = %*ENV{'SC_USERNAME'};
my $password = %*ENV{'SC_PASSWORD'};

if (defined $username && defined $password)
{
    plan 10;
}
else
{
    plan 10;
    skip-rest 'No $SC_USERNAME or $SC_PASSWORD defined';
    exit(0);
}



my $client-id = 'I2OBiw2wX09A9EAU5Qx4w';
my $client-secret = 'twr9Wj7Qw16qrChi2lpl4dxTEWix9JuSg8mOgdF52F8';

my %args = ( 
               redirect_uri => 'http://localhost/soundcloud/connect',
               scope         => 'non-expiring',
               username      => $username,
               password      => $password
            ) ;

ok(my $sc = WebService::Soundcloud.new( :$client-id, :$client-secret,|%args),"new object with credentials");

ok(my $token = $sc.get-access-token(), "get access token - no code needed");
ok(my $me = $sc.get-object('/me'), "get_object - /me");
ok($me.{'permalink'}, "and the data has something in it");
ok(my $tracks = $sc.get-list('/me/tracks'), 'get_list - "/me/tracks"');
ok(@($tracks), "and we got some tracks");
is(@($tracks), $me.{'track_count'}, "and the same as the number on the me");

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
