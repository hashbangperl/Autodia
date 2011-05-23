use Test::More;
if ($ENV{AUTHOR_TESTS}) {
  eval { require Test::Kwalitee; Test::Kwalitee->import() } ;
  plan( skip_all => 'Test::Kwalitee not installed; skipping' ) if ($@);
} else {
plan( skip_all => 'only run Test::Kwalitee when $ENV{AUTHOR_TESTS} set');
}

