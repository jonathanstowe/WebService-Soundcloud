package WebService::Soundcloud;
use 5.006;

use strict;
use warnings;

# Load custom modules
use LWP::UserAgent;
use URI;
use JSON qw(decode_json);
use Data::Dumper;
use HTTP::Headers;

# declare domains
our %domain_for = (
    'prod'        => 'https://api.soundcloud.com/',
    'production'  => 'https://api.soundcloud.com/',
    'development' => 'https://api.sandbox-soundcloud.com/',
    'dev'         => 'https://api.sandbox-soundcloud.com/',
    'sandbox'     => 'https://api.sandbox-soundcloud.com/'
);

our $DEBUG    = 1;
our %path_for = (
    'authorize'    => 'connect',
    'access_token' => 'oauth2/token'
);

our %formats = (
    '*'    => '*/*',
    'json' => 'application/json',
    'xml'  => 'application/xml'
);

our $VERSION = '0.01';

=pod

=head1 NAME

WebService::Soundcloud - Thin wrapper around Soundcloud RESTful API!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    #!/usr/bin/perl
    use WebService::Soundcloud;
    
    my $scloud = WebService::Soundcloud->new($client_id, $client_secret, 
                           { redirect_uri => 'http://mydomain.com/callback' }
                         );
    
    # Now get authorization url
    my $authorization_url = $scloud->get_authorization_url();
    
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

The above code is a basic usage of WebService::Soundcloud usage in a web environment.
See sections mentioned below to get more insight into its feature set.

=head1 DESCRIPTION

This module provides a wrapper around Soundcloud RESTful API to work with 
different kinds of soundcloud resources. It contains many functions for 
convenient use rather than standard Soundcloud RESTful API.

Following functions are provided:

=head1 EXPORT

no functions will be exported by default

=head1 SUBROUTINES/METHODS

=over 4

=item I<PACKAGE>->new(<CLIENT_ID>, <CLIENT_SECRET>, <HASHREF>)

Returns a newly created C<WebService::Soundcloud> object. The first arguement is 
client_id, the second arguement is client_secret.Soundcloud will provide you
with client_id, client_secret when you register your application with them. 
The third optional arguement is an anonymous hash contains key value pairs 
that can be used across created object.

=cut

sub new {
    my $class         = shift;
    my $client_id     = shift;
    my $client_secret = shift;
    my $options       = shift;
    $options->{client_id}     = $client_id;
    $options->{client_secret} = $client_secret;
    $options->{debug}         = $DEBUG unless ( $options->{debug} );
    $options->{user_agent}    = LWP::UserAgent->new;

    # Set default response format to json
    $options->{response_format} = 'json' unless ( $options->{response_format} );
    $options->{request_format}  = 'json' unless ( $options->{request_format} );
    my $self = bless $options, $class;
    return $self;
}

=item I<$OBJ>->get_authorization_url()

This method is used to get authorization url, user should be redirected for 
authenticate from soundcloud. This will return URL to which user should be redirected.

=cut

sub get_authorization_url {
    my ( $self, $args ) = @_;
    my $call   = 'get_authorization_url';
    my $params = {
        client_id     => $self->{client_id},
        client_secret => $self->{client_secret},
        redirect_uri  => $self->{redirect_uri},
        response_type => 'code'
    };
    $params = { %{$params}, %{$args} } if ref($args) eq 'HASH';
    my $authorize_url = $self->_build_url( $path_for{'authorize'}, $params );
    return $authorize_url;
}

=item I<$OBJ>->get_access_token(<CODE>)

This method is used to receive access_token, refresh_token, scope, expires_in details
from soundcloud once user is authenticated. access_token, refresh_token should be 
stored as it should be sent along with every request to access private resources 
on the user behalf.

=cut

sub get_access_token {
    my ( $self, $code, $args ) = @_;
    my $request;
    my $call   = 'get_access_token';
    my $params = {
        'code'          => $code,
        'client_id'     => $self->{client_id},
        'client_secret' => $self->{client_secret},
        'redirect_uri'  => $self->{redirect_uri},
        'grant_type'    => 'authorization_code'
    };

    $params = { %{$params}, %{$args} } if ref($args) eq 'HASH';
    return $self->_access_token($params);
}

=item I<$OBJ>->get_access_token_refresh(<REFRESH_TOKEN>)

This method is used to get new access_token by exchanging refresh_token once the
earlier access_token is expired. You will receive access_token, refresh_token, scope, 
expires_in details from soundcloud. access_token, refresh_token should be stored as 
it should be sent along with every request to access private resources on the user behalf.

=cut

sub get_access_token_refresh {
    my ( $self, $refresh_token, $args ) = @_;
    my $params = {
        'refresh_token' => $refresh_token,
        'client_id'     => $self->{client_id},
        'client_secret' => $self->{client_secret},
        'redirect_uri'  => $self->{redirect_uri},
        'grant_type'    => 'refresh_token'
    };
    $params = { %{$params}, %{$args} } if ref($args) eq 'HASH';
    return $self->_access_token($params);
}

=item I<$OBJ>->request(<METHOD>, <URL>, <HEADERS>, <CONTENT>)

This method is used to dispatch any type of HTTP requests by mentioning 
GET, POST, PUT, DELETE for METOD parameter on the given <URL>(second arguement).
The third optional arguement(<HEADERS>) is used to send headers. Forth optional arguement 
is used to send content to the <URL>. This method will return HTTP::Response object

=cut

sub request {
    my ( $self, $method, $url, $headers, $content ) = @_;
    return $self->{user_agent}
      ->request( HTTP::Request->new( $method, $url, $headers, $content ) );
}

=item I<$OBJ>->get(<URL>, <PARAMS>, <HEADERS>)

This method is used to dispatch GET request on the give URL(first arguement).
second arguement is an anonymous hash request parameters to be send along with GET request.
The third optional arguement(<HEADERS>) is used to send headers. 
This method will return HTTP::Response object

=cut

sub get {
    my ( $self, $path, $params, $extra_headers ) = @_;
    my $url = $self->_build_url( $path, $params );
    my $headers = $self->_build_headers($extra_headers);
    return $self->request( 'GET', $url, $headers );
}

=item I<$OBJ>->post(<URL>, <CONTENT>, <HEADERS>)

This method is used to dispatch POST request on the give URL(first arguement).
second arguement is the content to be posted to URL.
The third optional arguement(<HEADERS>) is used to send headers.
This method will return HTTP::Response object

=cut

sub post {
    my ( $self, $path, $content, $extra_headers ) = @_;
    my $url     = $self->_build_url($path);
    my $headers = $self->_build_headers($extra_headers);
    return $self->request( 'POST', $url, $headers, $content );
}

=item I<$OBJ>->put(<URL>, <CONTENT>, <HEADERS>)

This method is used to dispatch PUT request on the give URL(first arguement).
second arguement is the content to be sent to URL.
The third optional arguement(<HEADERS>) is used to send headers.
This method will return HTTP::Response object

=cut

sub put {
    my ( $self, $path, $content, $extra_headers ) = @_;
    my $url = $self->_build_url($path);

# Set Content-Length Header as well otherwise nginx will throw 411 Length Required ERROR
    $extra_headers->{'Content-Length'} = 0
      unless $extra_headers->{'Content-Length'};
    my $headers = $self->_build_headers($extra_headers);
    return $self->request( 'PUT', $url, $headers, $content );
}

=item I<$OBJ>->delete(<URL>, <PARAMS>, <HEADERS>)

This method is used to dispatch DELETE request on the give URL(first arguement).
second optional arguement is an anonymous hash request parameters to be send 
along with DELETE request. The third optional arguement(<HEADERS>) is used to 
send headers. This method will return HTTP::Response object

=cut

sub delete {
    my ( $self, $path, $params, $extra_headers ) = @_;
    my $url = $self->_build_url( $path, $params );
    my $headers = $self->_build_headers($extra_headers);
    return $self->request( 'DELETE', $url, $headers );
}

=item I<$OBJ>->download(<TRACK_ID>, <DEST_FILE>)

This method is used to download a particular track id given as first arguement.
second arguement is name of the destination path where the downloaded track will 
be saved to. This method will return the file path of downloaded track.

=cut

sub download {
    my ( $self, $trackid, $file ) = @_;
    my $url =
      $self->_build_url( "/tracks/$trackid/download",
        { ':content_file' => $file } );

    # Set Response format to */*
    # Memorize old response format
    my $old_response_format = $self->{response_format};
    $self->{response_format} = $formats{'*'};
    my $headers = $self->_build_headers();
    my $response = $self->request( 'GET', $url, $headers );

    # Reset response format
    $self->{response_format} = $formats{$old_response_format};
    return $file;
}

=item I<$OBJ>->request_format(<TYPE>)

This method is used to set or get request format for current/future requests being
sent to soundcloud. Basically when you are setting request_format it will set 
'Content-Type' HTTP request header.

=cut

sub request_format {
    my ( $self, $format ) = @_;
    if ($format) {
        $self->{request_format} = $format;
    }
    else {
        return $self->{request_format};
    }
}

=item I<$OBJ>->response_format(<TYPE>)

This method is used to set or get response format for current/future requests being 
sent to soundcloud. Basically when you are setting response_format it will set 
'Accept' HTTP request header.

=cut

sub response_format {
    my ( $self, $format ) = @_;
    if ($format) {
        $self->{response_format} = $format;
    }
    else {
        return $self->{response_format};
    }
}

=back

=head1 INTERNAL SUBROUTINES/METHODS

Please do not use these internal methods directly. They are internal to 
WebService::Soundcloud module itself. These can be renamed/deleted/updated at any point 
of time in future.

=over 4

=item I<$OBJ>->_access_token(<PARAMS>)

This method is used to get access_token from soundcloud. This will be called 
from get_access_token and get_access_token_refresh methods.

=cut

sub _access_token {
    my ( $self, $params ) = @_;
    my $call     = '_access_token';
    my $url      = $self->_access_token_url($params);
    my $headers  = $self->_build_headers();
    my $response = $self->request( 'POST', $url, $headers );
    die "Failed to fetch " . $self->_access_token_url()
      unless $response->is_success;
    my $uri          = URI->new;
    my $access_token = decode_json( $response->decoded_content );

    # store access_token, refresh_token
    foreach (qw(access_token refresh_token expire expires_in)) {
        $self->{$_} = $access_token->{$_};
    }

    # set access_token, refresh_token
    return $access_token;
}

=item I<$OBJ>->_access_token_url(<PARAMS>)

This method is used to get access_token_url of soundcloud RESTful API. 
This will be called from _access_token method.

=cut

sub _access_token_url {
    my ( $self, $params ) = @_;
    my $url = $self->_build_url( $path_for{'access_token'}, $params );
    return $url;
}

=item I<$OBJ>->_build_url(<PATH>, PARAMS>)

This method is used to prepare absolute URL for a given path and request parameters.

=cut

sub _build_url {
    my ( $self, $path, $params ) = (@_);
    my $call = '_build_url';

    # get base URL
    my $base_url =
      $self->{development} ? $domain_for{development} : $domain_for{production};

    # Prepare URI Object
    my $uri = URI->new_abs( $path, $base_url );
    $uri->query_form( %{$params} );
    return $uri;
}

=item I<$OBJ>->_build_headers(<HEADERS>)

This method is used to set extra headers to the current HTTP Request.

=cut

sub _build_headers {
    my ( $self, $extra ) = @_;
    my $headers = HTTP::Headers->new;

    $headers->header( 'Accept' => $formats{ $self->{response_format} } )
      if ( $self->{response_format} );
    $headers->header( 'Content-Type' => $formats{ $self->{request_format} } )
      if ( $self->{request_format} );
    $headers->header( 'Authorization' => "OAuth " . $self->{access_token} )
      if ( $self->{access_token} );
    foreach my $key ( %{$extra} ) {
        $headers->header( $key => $extra->{$key} );
    }
    return $headers;
}

=item I<$OBJ>->log(<MSG>)

This method is used to write some text to STDERR.

=cut

sub log {
    my ( $self, $msg ) = @_;
    if ( $self->{debug} ) {
        print STDERR "$msg\n";
    }
}

=back

=head1 AUTHOR

Mohan Prasad Gutta, C<< <mohanprasadgutta at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-soundcloud at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-Soundcloud>.
I will be notified, and then you'll automatically be notified of progress on your bug 
as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.
    perldoc WebService::Soundcloud
You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-Soundcloud>

=item * AnnoCPAN: Annotated CPAN documentation
L<http://annocpan.org/dist/WebService-Soundcloud>

=item * CPAN Ratings
L<http://cpanratings.perl.org/d/WebService-Soundcloud>

=item * Search CPAN
L<http://search.cpan.org/dist/WebService-Soundcloud/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohan Prasad Gutta.
This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.
See http://dev.perl.org/licenses/ for more information.

=cut

1;
