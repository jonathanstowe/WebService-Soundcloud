use v6;

=begin pod

=head1 NAME

WebService::Soundcloud - Thin wrapper around Soundcloud RESTful API!

=head1 VERSION

Version 0.0.1

=head1 SYNOPSIS

    #!/usr/bin/perl6
    use WebService::Soundcloud;
    
    my $scloud = WebService::Soundcloud.new(:$client-id, :$client-secret, redirect-uri => 'http://mydomain.com/callback' );
    
    # Now get authorization url
    my $authorization_url = $scloud.get-authorization-url();
    
    # Redirect the user to authorization url
    use CGI;
    my $q = new CGI;
    $q->redirect($authorization_url);
    
    # In your '/callback' handler capture code params
    # Check for error
    if ($q->param(error)) {
    	die "Authorization Failed: ". $q->param('error');
    }
    # Get authorization code
    my $code = $q->param('code');
    
    # Get Access Token
    my $access_token = $scloud->get_access_token($code);
    
    # Save access_token and refresh_token, expires_in, scope for future use
    my $oauth_token = $access_token->{access_token};
    
    # OAuth Dance is completed :-) Have fun now.

    # Default request and response formats are 'json'
    
    # a GET request '/me' - gets users details
    my $user = $scloud->get('/me');
    
    # a PUT request '/me' - updated users details
    my $user = $scloud->put('/me', encode_json(
                { 'user' => {
                  'description' => 'Have fun with Perl wrapper to Soundcloud API'
                } } ) );
                
    # Comment on a Track POSt request usage
    my $comment = $scloud->post('/tracks/<track_id>/comments', 
                            { body => 'I love this hip-hop track' } );
    
    # Delete a track
    my $track = $scloud->delete('/tracks/{id}');
    
    # Download a track
    my $file_path = $scloud->download('<track_id>', $dest_file);


=head1 DESCRIPTION

This module provides a wrapper around Soundcloud RESTful API to work with 
different kinds of soundcloud resources. It contains many functions for 
convenient use rather than standard Soundcloud RESTful API.

The complete API is documented at http://developers.soundcloud.com/docs.

In order to use this module you will need to register your application
with Soundcloud at http://soundcloud.com/you/apps : your application will
be given a client ID and a client secret which you will need to use to 
connect.

=head2 METHODS


=head3 new

Returns a newly created C<WebService::Soundcloud> object. The first
named argument is client-id, the second argument is client-secret - these
are required and will have been provided when you registered your
application with Soundcloud. 

=head3 client-id

Accessor for the Client ID that was provided when you registered your
application.


=head3 client-secret

Accessor for the Client Secret that was provided when you registered
your application.

=head3 redirect-uri

Accessor for the redirect_uri this can be passed as an option to the
constructor or supplied later (before any connect call.) This should
match to that provided when you registered your application.

This can be supplied as an option to the constructor.

It is the URI of your application that the user will be redirected
(with the authorization code as a parameter,) after they have clicked
"Connect" on the soundcloud connect page.  This will not be used if
you are using the credential based authentication to obtain the OAuth token
(e.g if you are an application with no UI that is operating for a single
user.) 

=head3 basic-params

This returns a L<Hash> that is suitable to be used as the basic parameters
in most places, containing the application credentials (ID and Secret) and
redirect_uri

=head3 ua

Returns the L<LWP::UserAgent> object that will be used to connect to the
API host


=head3 get-authorization-url

This method is used to get authorization url, user should be redirected
for authenticate from soundcloud. This will return URL to which user
should be redirected.

=head3 get-access-token

This method is used to receive access_token, refresh_token,
scope, expires_in details from soundcloud once user is
authenticated. access_token, refresh_token should be stored as it should
be sent along with every request to access private resources on the
user behalf.

The argument C<$code> is required unless you are using credential based
authentication, and will have been supplied to your C<redirect_uri> after
the user pressed "Connect" on the soundcloud connect page.

=head3 get-access-token-refresh

This method is used to get new access_token by exchanging refresh_token
before the earlier access_token is expired. You will receive new
access_token, refresh_token, scope and expires_in details from
soundcloud. access_token, refresh_token should be stored as it should
be sent along with every request to access private resources on the
user behalf.

If a C<scope> of 'non-expiring' was supplied at the time the initial tokem
was obtained then this should not be necessary.

=head3 request

This performs an HTTP request with the $method supplied to the supplied
$url. The third argument $headers can be supplied to insert any required
headers into the request, if $content is supplied it will be processed
appropriately and inserted into the request.

An L<HTTP::Response> will be returned and this should be checked to
determine the status of the request.

=head3 get-object

This returns a decoded object corresponding to the URI given

It will for the response_format to 'json' for the request as
parsing the XML is tricky given no schema.

=head3 get-list

This returns an L<Array> of the list method specified by URI

Currently this will force response_format to 'json' as parsin the XML
is tricky without a schema.

=item get(<URL>, <PARAMS>, <HEADERS>)

This method is used to dispatch GET request on the give URL(first argument).
second argument is an anonymous hash request parameters to be send along with GET request.
The third optional argument(<HEADERS>) is used to send headers. 
This method will return HTTP::Response object


=head3 I<$OBJ>->post(<URL>, <CONTENT>, <HEADERS>)

This method is used to dispatch POST request on the give URL(first argument).
second argument is the content to be posted to URL.
The third optional argument(<HEADERS>) is used to send headers.
This method will return HTTP::Response object

=head3 I<$OBJ>->put(<URL>, <CONTENT>, <HEADERS>)

This method is used to dispatch PUT request on the give URL(first argument).
second argument is the content to be sent to URL.
The third optional argument(<HEADERS>) is used to send headers.
This method will return HTTP::Response object

=head3 I<$OBJ>->delete(<URL>, <PARAMS>, <HEADERS>)

This method is used to dispatch DELETE request on the give URL(first argument).
second optional argument is an anonymous hash request parameters to be send 
along with DELETE request. The third optional argument(<HEADERS>) is used to 
send headers. This method will return HTTP::Response object

=item I<$OBJ>->download(<TRACK_ID>, <DEST_FILE>)

This method is used to download a particular track id given as first argument.
second argument is name of the destination path where the downloaded track will 
be saved to. This method will return the file path of downloaded track.

=head3 request-format

Accessor for the request format to be used.  Acceptable values are 'json' and
'xml'.  The default is 'json'.

=head3 response-format

Accessor for the response format to be used.  The allowed values are 'json'
and 'xml'.  The default is 'json'.  This will cause the appropriate setting
of the Accept header in requests.

=head3 parse_content

This will return the parsed object corresponding to the response content
passed as asn argument.  It will select the appropriate parser based on the
value of 'response_format'.

It will return undef if there is a problem with the parsing.

=head3 _our_redirect

This subroutime is intended to be used as a callback on 'response_redirect'
It processes the response to make a new request for the redirect with the
Authorization header removed so that EC3 doesn't get confused.

=head3 _is_redirect

Helper subroutine to determine if the code indicates a redirect.

=head3 I<$OBJ>->log(<MSG>)

This method is used to write some text to STDERR.

=end pod

class WebService::Soundcloud:ver<v0.0.1> {

    use HTTP::UserAgent;
    use URI;
    use JSON::Tiny;
    #use HTTP::Headers;

    # declare domains
    our %domain-for = (
        'prod'        => 'https://api.soundcloud.com/',
        'production'  => 'https://api.soundcloud.com/',
        'development' => 'https://api.sandbox-soundcloud.com/',
        'dev'         => 'https://api.sandbox-soundcloud.com/',
        'sandbox'     => 'https://api.sandbox-soundcloud.com/'
    );

    our $DEBUG    = False;

    our %path-for = (
        'authorize'    => 'connect',
        'access_token' => 'oauth2/token'
    );

    our %formats = (
        '*'    => '*/*',
        'json' => 'application/json',
        'xml'  => 'application/xml'
    );


    has Str $.client-id;
    has Str $.client-secret;
    has %!options;
    has Str $.redirect-uri is rw;
    has HTTP::UserAgent $.ua is rw;
    has Bool $!development = False;
    has $!scope;
    has Str $.username is rw;
    has Str $.password is rw;
    has Str $.response-format is rw = 'json';
    has Str $.request-format is rw = 'json';
    has %!auth-details;
    has Bool $!debug = False;

    submethod BUILD(:$!client-id!, :$!client-secret!, :$!redirect-uri, :$!scope, :$!username, :$!password, :$!ua, *%opts) {

        %!options = %opts;
        if not $!ua.defined {
            $!ua  = HTTP::UserAgent.new;
        }
    }



    method basic-params() is rw {
        my %params = (
            client_id       => $!client-id,
            client_secret   => $!client-secret,
        );

        if $!redirect-uri.defined {
            %params<redirect_uri> = $!redirect-uri;
        }

        return %params;
    }


    method get-authorization-url(*%args) {
        my $call   = 'get_authorization_url';
        my %params = self.basic-params();

        %params<response_type> = 'code';

        %params =  %params, %args;

        self!build-url( %path-for<authorize>, %params );
    }


    method get-access-token(Str $code, *%args) {

        my %params = self!access-token-params($code);

        %params =  %params, %args;
        self!access-token(%params);
    }

    method !access-token-params(Str $code?) {
        my %params = !self.basic-params();

        if  $!scope.defined {
            %params<scope> = $!scope;
        }
        if $!username && $!password {
            %params<username>   = $!username;
            %params<password>   = $!password;
            %params<grant_type> = 'password';
        }
        elsif $code.defined {
            %params<code>       = $code;
            %params<grant_type> = 'authorization_code';
        }
        else {
            die "neither credentials or auth code provided";
        }
        %params;
    }


    method get-access-token-refresh(Str $refresh-token, *%args) {
        my %params = self.basic-params();

        %params<refresh_token> = $refresh-token;
        %params<grant_type>    = 'refresh_token';

        %params =  %params, %args;
        self!access-token(%params);
    }


    method request($method, $url, %headers, $content?) returns HTTP::Response {
        my $req = HTTP::Request.new( $method, $url, %headers );

        if $content.defined {
            my $u = URI.new();
            $u.query_form($content);
            my $query = $u.query();
            $req.content($query);
        }
        self.log($req);
        $!ua.request($req);
    }


    method get-object($url, %params, %headers ) {
        my $obj;

        my $save_response_format = $!response-format;
        $!response-format = 'json';

        my HTTP::Response $res = self.get( $url, %params, %headers );

        if  $res.is-success {
            $obj = from-json( $res.decoded-content );
        }

        $!response-format = $save_response_format;
        $obj;
    }


    method get-list($url, %params, %headers) {
        my @ret;
        my Bool $continue = True;
        my Int $offset   = 0;
        my Int $limit    = 50;

        my $save_response_format = $!response-format;
        $!response-format        = 'json';

        while $continue {
            %params<limit>  = $limit;
            %params<offset> = $offset;

            my $res = self.get( $url, %params, %headers );

            if  $res.is-success {
                if (my $obj = self.parse-content( $res.decoded-content)).defined {
                    if $obj ~~ Array {
                        $offset += $limit;
                        $continue = $obj.elems > 0;
                    }
                    elsif $obj ~~ Hash {
                        if $obj<collection>:exists {
                            $url = $obj<next_href>;
                            $continue = $url.defined;
                            $obj = $obj<collection>;
                        }
                        else {
                            die "not a collection";
                        }
                    }
                    else {
                        die "Unexpected { $obj.WHAT } reference instead of list";
                    }
                    @ret.push($obj);
                }
                else {
                    $continue = False;
                }
            }
            else {
                warn $res.request.uri;
                die $res.status-line;
            }
        }
        $!response-format = $save_response_format;
        @ret;
    }

    method get( Str $path, %params, %extra_headers ) {
        my $url = self!build-url( $path, %params );
        my %headers = self!build-headers(%extra_headers);
        self.request( 'GET', $url, %headers );
    }


    method post(Str $path, $content, %extra_headers ) {
        my $url     = self!build-url($path);
        my %headers = self!build-headers(%extra_headers);
        self.request( 'POST', $url, %headers, $content );
    }


    method put( Str $path, $content, %extra_headers ) {
        my $url = self!build-url($path);

        %extra_headers<Content-Length> = 0 unless %extra_headers<Content-Length>;
        my %headers = self!build-headers(%extra_headers);
        self.request( 'PUT', $url, %headers, $content );
    }

    method delete(Str $path, %params, %extra_headers ) {
        my $url = self!build-url( $path, %params );
        my %headers = self!build-headers(%extra_headers);
        self.request( 'DELETE', $url, %headers );
    }


    method download( $trackid, $file ) {
        my $url = self!build-url( "/tracks/$trackid/download");
        self.log($url);

        my Bool $rc = False;
        # Set Response format to */*
        # Memorize old response format
        my $old_response_format = $!response-format;
        $!response-format = '*';
        my %headers = self!build-headers();
        #$self.ua().add_handler('response_redirect',\&_our_redirect);
        my $response = self.request( 'GET', $url, %headers );

        #$self.ua().remove_handler('response_redirect');

        if !($rc = $response.is_success()) {
            self.log($response.request);
            self.log($response);
            for ( $response.redirects() ) -> $red {
                self.log($red.request);
                self.log($red);
            }
        }
        $!response-format = $old_response_format;
        $rc;
    }


    sub our-redirect( $response, $ua, $h ) {
        my $code = $response.code();

        my $req;

        if is-redirect($code) {
            my $referal =  $response.request().clone();
            $referal.remove_header('Host','Cookie','Referer','Authorization');

            if (my $ref_uri = $response.header('Location'))
            {
                my $uri = URI.new($ref_uri);
                $referal.header('Host' => $uri.host());
                $referal.uri($uri);
                if ( $ua.redirect_ok($referal, $response) )
                {
                    $req = $referal;
                }
            }
        }
        $req;
    }


    sub is-redirect(Int() $code) returns Bool {
        my Bool $rc = False;

        $rc = ($code ~~ 301|302|303|307);
        $rc;
    }



    method parse-content(Str $content) {
        my $object;

        given $!response-format {
            when 'json' {
                $object = from-json($content);
            }
            when 'xml' {
                # for the time being
                require XML::Simple:from<Perl5>;
                my $xs = XML::Simple.new();
                $object = $xs.XMLin($content);
            }
        }
        CATCH {
            default {
                warn $_;
            }
        }
        $object;
    }

    method !access-token(%params) {
        my $call     = '_access_token';
        my $url      = self!access-token-url();
        my $headers  = self!build-headers();
        my $response = self.request( 'POST', $url, $headers, %params );

        if ! $response.is-success() {
            die "Failed to fetch " 
                ~ $url ~ " "
                ~ $response.content() ~ " ("
                ~ $response.status_line() ~ ")"
        }
        my $uri          = URI.new;
        my $access_token = from-json( $response.content );

        # store access_token, refresh_token
        # Needs an object
        for <access_token refresh_token expire expires_in> {
            %!auth-details{$_} = $access_token{$_};
        }

        # set access_token, refresh_token
        $access_token;
    }

    method !access-token-url(*%params) {
        self!build-url( %path-for<access_token>, %params );
    }

    method !build-url(Str $path, *%params) {
        my $base_url = $!development ?? %domain-for<development> !! %domain-for<production>;

        my $uri = URI.new_abs( $path, $base_url );
   
        if  $uri.query.defined {
            %params = %params,$uri.query-form();
        }
        $uri.query_form( %params );
        $uri;
    }


    method !build-headers(*%extra) returns HTTP::Header {
        my $headers = HTTP::Header.new;

        if $!response-format.defined {
            $headers.field( Accept => %formats{ $!response-format } );
        }
        if $!request-format.defined {
            $headers.field( Content-Type => %formats{ $!request-format } ~ '; charset=utf-8' );
        }
        if %!auth-details<access_token>.defined && not %extra<no_auth>:exists {
            $headers.field( 'Authorization' => "OAuth " ~ %!auth-details<access_token> );
        }
        for  %extra.kv -> $key, $value {
            $headers.field( $key => $value );
        }
        $headers;
    }


    method log(Str() $msg) {
        if $!debug {
            $*ERR.say($msg);
        }
    }



}
# vim: ft=perl6 expandtab sw=4
