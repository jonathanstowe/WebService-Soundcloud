use JSON::Class;
use JSON::Name;

class WebService::Soundcloud::User does JSON::Class {
    has Int $.id;
    has Str $.uri;
    has Str $.website;
    has Str $.plan;
    has Str $.permalink_url;
    has Str $.last_name;
    has Any $.myspace_name;
    has Int $.track_count;
    has Int $.playlist_count;
    has Str $.country;
    has Str $.full_name;
    has Int $.followings_count;
    has  @.subscriptions;
    has Str $.last_modified;
    has Str $.city;
    has Int $.followers_count;
    has Str $.description;
    has Str $.website_title;
    has Bool $.online;
    has Str $.avatar_url;
    has Str $.first_name;
    has Any $.discogs_name;
    has Str $.kind;
    has Str $.permalink;
    has Str $.username;
    has Int $.public_favorites_count;
}
# vim: expandtab shiftwidth=4 ft=perl6
