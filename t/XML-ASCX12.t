# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl XML-ASCX12.t'

#########################

use File::Compare;

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 25;
BEGIN { use_ok('XML::ASCX12 0.03') };

# foreach my $p (keys %INC) {
# 	warn "$p $INC{$p}\n";
# }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $obj = XML::ASCX12->new;
isa_ok( $obj, 'XML::ASCX12');

# Catalogs.pm default catalog
ok ($obj->load_catalog(0), 'Default catalog load');
is ($XML::ASCX12::Catalogs::LOOPNEST->{ISA}->[0],'GS', 'ISA begats GS'); 
is ($XML::ASCX12::Catalogs::LOOPNEST->{GS}->[0],'ST', 'GS begats ST'); 

# Segments.pm
ok ($XML::ASCX12::Segments::SEGMENTS->{ISA}, 'Segment ISA Definition'); 
ok ($XML::ASCX12::Segments::SEGMENTS->{IEA}, 'Segment IEA Definition'); 
ok ($XML::ASCX12::Segments::SEGMENTS->{GS}, 'Segment GS Definition'); 
ok ($XML::ASCX12::Segments::SEGMENTS->{GE}, 'Segment GE Definition'); 
ok ($XML::ASCX12::Segments::SEGMENTS->{ST}, 'Segment ST Definition'); 
ok ($XML::ASCX12::Segments::SEGMENTS->{SE}, 'Segment SE Definition'); 
ok ($XML::ASCX12::Segments::ELEMENTS->{ISA01}, 'Element ISA01 Definition'); 
ok ($XML::ASCX12::Segments::ELEMENTS->{ST02}, 'Element ST02 Definition'); 
ok ($XML::ASCX12::Segments::ELEMENTS->{SE02}, 'Element SE02 Definition'); 

# tests using the sample file provided with version 0.03
my $sample = 'INV.110.SAMPLE';
my $examples = './examples'; ## for make test
unless (-d $examples) {
	$examples = '../examples'; ## run from t directory
}
my $file = "$examples/$sample";
my $fileref = "$file.ref";
my $fileout = "./$sample.xml"; ## create in running directory

SKIP: {
	skip "No sample file found at $file\n", 1 unless (-e $file);
	unlink "$fileout"; ## cleanup, file may not exist
	ok (not (-e $fileout), 'Confirm no output');
	ok (-r $file, 'Sample file can be read');
	ok (-r $fileref, 'Reference file can be read');
	ok ( $obj->convertfile($file, $fileout), 'convertfile sample');
	ok (-e $fileout, 'Sample output created');
	ok (compare($fileout, $fileref) == 0, 'Compare XML to reference');

	## read sample into variable, from example test1
	my $edi;
	open (TFH, "< $file");
	binmode(TFH);
	while(<TFH>) {
	    $/ = '';
	    chomp;
	    $edi .= $_;
	}
	close(TFH);

	## sanity checks on beginning and end
	ok ($edi =~ /^ISA/, 'Begins with "ISA"');
	ok ($edi =~ /IEA/, 'Includes final "IEA"');
	my $xml1;
	ok ($xml1 = $obj->convertdata($edi), 'convertdata sample');
	open (REF, "< $fileref");
	binmode(REF);
	$/ = undef;
	my $xml2 = <REF>;
	close(REF);

	## BUG: Version 0.03 omits closing tag convertdata only
	if ($XML::ASCX12::VERSION < 0.05) {
		$xml1 .= '</ascx:message>';
	}
	is (length($xml1), length($xml2), 'Compare size with data from reference');
	is ($xml1, $xml2, 'Compare variable with data from reference');
}
