var result, i, j;

result = true;

function xmlEncode( string ) {
    return string.replace( '&', '&amp;', 'g' ).replace( '<', '&lt;', 'g' ).replace( '>', '&gt;', 'g' ).replace( '"', '&quot;', 'g' );
}

print( '<?xml version="1.0" encoding="UTF-8"?>' );
print( '<checkstyle version="1.3.3">' );
for ( i in arguments ) {
    print( ' <file name="' + arguments[i] + '">' );
    if ( !JSLINT( readFile( arguments[i] ) ) ) {
        result = false;
        for ( j in JSLINT.errors ) {
            var error = JSLINT.errors[j];

            if ( !error ) {
                break;
            }

            print( '  <error line="' + error.line + '" column="' + error.character + '" severity="error" message="' + xmlEncode( error.reason ) + '" source="JSLint"/>' );
        }
    }
    print( ' </file>' );
}
print( '</checkstyle>' );

quit( result ? 0 : 1 );

