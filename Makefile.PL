
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'configure Dist::Zilla like RUSSOZ',
  'AUTHOR' => 'Alexei Znamensky <russoz@cpan.org>',
  'BUILD_REQUIRES' => {
    'English' => '0',
    'File::Find' => '0',
    'File::Temp' => '0',
    'Test::More' => '0.88',
    'perl' => '5.006'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.30'
  },
  'DISTNAME' => 'Dist-Zilla-PluginBundle-Author-RUSSOZ',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Dist::Zilla::PluginBundle::Author::RUSSOZ',
  'PREREQ_PM' => {
    'Dist::Zilla' => '4.102341',
    'Dist::Zilla::Plugin::InstallGuide' => '0',
    'Dist::Zilla::Plugin::MetaJSON' => '0',
    'Dist::Zilla::Plugin::ReadmeFromPod' => '0',
    'Dist::Zilla::Plugin::Signature' => '0',
    'Dist::Zilla::PluginBundle::TestingMania' => '0.012',
    'Dist::Zilla::Role::PluginBundle::Easy' => '0',
    'Moose' => '0.99',
    'Pod::Elemental::Transformer::List' => '0',
    'Pod::Weaver::Config::Assembler' => '0',
    'Pod::Weaver::Plugin::Encoding' => '0.01',
    'Pod::Weaver::Section::SeeAlso' => '1.002',
    'Pod::Weaver::Section::Support' => '1.003',
    'Pod::Weaver::Section::WarrantyDisclaimer' => '0.103511',
    'namespace::autoclean' => '0.09',
    'namespace::clean' => '0'
  },
  'VERSION' => '0.008',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



