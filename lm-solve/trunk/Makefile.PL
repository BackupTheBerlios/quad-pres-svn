use ExtUtils::MakeMaker;

my $version;

open VER, "<ver.txt";
$version = <VER>;
chomp($version);
close(VER);

WriteMakefile(
    'NAME' => 'Games::LMSolve',
    'DISTNAME' => 'Games-LMSolve',
    'EXE_FILES' => ["lm-solve"],
    'VERSION' => $version,
    );

print "Generating the RPM SPEC file\n";
open I, "<lm-solve.spec.in";
open O, ">lm-solve.spec";
while (<I>)
{
    s!\[\[VERSION\]\]!$version!g;
    print O $_;
}
close(O);
close(I);

