#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and https://www.varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

# Basic help
# Restart: /etc/init.d/varnish restart
# Test config: varnishd -C -f /etc/varnish/default.vcl
# Dump log to file: varnishlog -A -w /path/to/file

# Imports
import std;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "ec2-52-206-74-238.compute-1.amazonaws.com";
    .port = "8080";
    .connect_timeout = 20ms;
    .first_byte_timeout = 50ms;
}

sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.

    # For more info ask vadim.moshinsky
    
    # Debug before
    # std.log("INPUT: HOST - " + req.http.host + " | URL - " + req.url);
    
    # Remove everything after "?" or "#" signs
    # Example: (note that characters are encoded)
    # Input  1 - /db2/client/49600/all.json?adsafe_url=http%3A%2F%2Fwww.example.com%2Ffruits%3Fcolor%3Dred
    # Output 1 - /db2/client/49600/all.json?adsafe_url=http%3A%2F%2Fwww.example.com%2Ffruits
    # Input  2 - /db2/client/49600/all.json?adsafe_url=http%3A%2F%2Fwww.example.com%2Ffruits%23apple
    # Output 2 - /db2/client/49600/all.json?adsafe_url=http%3A%2F%2Fwww.example.com%2Ffruits
    set req.url = regsub(req.url, "%(3F|23).*", "");
    
    # Debug after
    # std.log("OUTPUT: HOST - " + req.http.host + " | URL - " + req.url);
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.
    
    # Unset cache preventing headers
    unset beresp.http.Pragma;
    unset beresp.http.Cache-Control;

    # Set cached object TTL
    set beresp.ttl = 12h;
}

sub vcl_backend_error {
    # Happens if we fail the backend fetch or if max_retries has been exceeded.
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.

    # Unset Varnish specific headers
    unset resp.http.Age;
    unset resp.http.Via;
    unset resp.http.X-Varnish;
}
