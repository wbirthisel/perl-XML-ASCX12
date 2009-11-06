# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl cat_175.t'

#########################
use lib '../lib';

use File::Compare;

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 36;
BEGIN { use_ok('XML::ASCX12 0.11') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# default delimiters
$obj = XML::ASCX12->new();
isa_ok( $obj, 'XML::ASCX12');
is($obj->segment_terminator, '\x85', 'Default segment_terminator');
is($obj->data_element_separator, '\x1D', 'Default data_element_separator');
is($obj->subelement_separator, '\x1F', 'Default subelement_separator');
# change delimiters
is($obj->segment_terminator('\x40'), '\x40', 'set segment_terminator');
is($obj->data_element_separator('A'), 'A', 'set data_element_separator');
is($obj->subelement_separator(0), 0, 'set subelement_separator');
undef $obj;

# specify and check delimiters for catalog 175
$obj = XML::ASCX12->new('\x0A','\x7C');
isa_ok( $obj, 'XML::ASCX12');
is($obj->segment_terminator, '\x0A', 'catalog 175 segment_terminator');
is($obj->data_element_separator, '\x7C', 'catalog 175 data_element_separator');
is($obj->subelement_separator, '\x1F', 'Default subelement_separator not changed');

# tests using the sample files provided with version 0.04
my $examples = './examples'; ## for make test
unless (-d $examples) {
	$examples = '../examples'; ## run from t directory
}
foreach my $e (1..4) {
    my $file = "$examples/example_$e.edi";
    my $fileref = "$examples/example_$e.ref";
    my $fileout = "./example_$e.xml"; ## create in running directory
    unlink "$fileout"; ## cleanup, file may not exist
    ok (not (-e $fileout), "Confirm no output $fileout");

    SKIP: {
    	skip "No sample file found at $file\n", 1 unless (-e $file);
    	ok (-r $file, 'Sample file can be read');
    	ok (-r $fileref, 'Reference file can be read');
    	ok ( $obj->convertfile($file, $fileout), 'convertfile sample');
    	ok (-e $fileout, 'Sample output created');
    	ok (compare($fileout, $fileref) == 0, 'Compare XML to reference');
    }
}
