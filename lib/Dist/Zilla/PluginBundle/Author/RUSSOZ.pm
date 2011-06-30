package Dist::Zilla::PluginBundle::Author::RUSSOZ;

use strict;
use warnings;

# ABSTRACT: configure Dist::Zilla like RUSSOZ
our $VERSION = '0.012'; # VERSION

use Moose 0.99;
use namespace::autoclean 0.09;

use Dist::Zilla 4.102341;    # dzil authordeps
use Dist::Zilla::PluginBundle::TestingMania 0.012;
use Dist::Zilla::Plugin::MetaJSON;
use Dist::Zilla::Plugin::ReadmeFromPod;
use Dist::Zilla::Plugin::InstallGuide;
use Dist::Zilla::Plugin::Signature;

with 'Dist::Zilla::Role::PluginBundle::Easy';

has auto_prereqs => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => 1,
);

has no404 => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub {
        ( defined $_[0]->payload->{no404} and $_[0]->payload->{no404} == 1 )
          ? 1
          : 0;
    },
);

has github => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub {
        ( defined $_[0]->payload->{github} and $_[0]->payload->{github} == 0 )
          ? 0
          : 1;
    },
);

has twitter => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub {
        ( defined $_[0]->payload->{no_twitter}
              and $_[0]->payload->{no_twitter} == 1 ) ? 0 : 1;
    },
);

has twitter_tags => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my @t =
          defined( $_[0]->payload->{twitter_tags} )
          ? ( $_[0]->payload->{twitter_tags} )
          : ();
        return join( ' ', q{#cpan}, q{#perl}, @t );
    },
);

has task_weaver => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub {
        ( defined $_[0]->payload->{task_weaver}
              and $_[0]->payload->{task_weaver} == 1 ) ? 1 : 0;
    },
);

has signature => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub {
        ( defined $_[0]->payload->{signature}
              and $_[0]->payload->{signature} == 0 ) ? 0 : 1;
    },
);

sub configure {
    my $self = shift;

    $self->add_bundle('Basic');

    $self->add_plugins(
        'MetaJSON',
        'ReadmeFromPod',
        'InstallGuide',
        [
            'GitFmtChanges' => {
                max_age    => 365,
                tag_regexp => q{^.*$},
                file_name  => q{Changes},
                log_format => q{short},
            }
        ],

        'OurPkgVersion',
    );

    $self->add_plugins('GithubMeta')  if $self->github;
    $self->add_plugins('AutoPrereqs') if $self->auto_prereqs;

    if ( $self->task_weaver ) {
        $self->add_plugins('TaskWeaver');
    }
    else {
        $self->add_plugins( 'ReportVersions::Tiny',
            [ 'PodWeaver' => { config_plugin => '@Author::RUSSOZ' }, ],
        );

        $self->add_plugins('Test::UseAllModules');
        $self->add_bundle( 'TestingMania' =>
              { disable => q{Test::CPAN::Changes,SynopsisTests}, } );
        $self->add_plugins('Test::Pod::No404s')
          if ( $self->no404 || $ENV{NO404} );
    }

    $self->add_plugins(
        [
            'Twitter' => {
                hash_tags => $self->twitter_tags,
                tweet_url =>
                  q(http://search.cpan.org/~{{$AUTHOR_LC}}/{{$DIST}}),
                url_shortener => 'TinyURL',
            }
        ]
    ) if ( $self->twitter );

    $self->add_plugins('Signature') if $self->signature;

    return;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;



=pod

=encoding utf-8

=head1 NAME

Dist::Zilla::PluginBundle::Author::RUSSOZ - configure Dist::Zilla like RUSSOZ

=head1 VERSION

version 0.012

=head1 SYNOPSIS

	# in dist.ini
	[@Author::RUSSOZ]
	; auto_prereqs = 1
	; github = 1
	; no404 = 0
	; task_weaver = 0
	; no_twitter = 0
	; twitter_tags = <empty>
	; signature = 1

=head1 DESCRIPTION

C<Dist::Zilla::PluginBundle::Author::RUSSOZ> provides shorthand for
a L<Dist::Zilla> configuration approximately like:

	[@Basic]

	[MetaJSON]
	[ReadmeFromPod]
	[InstallGuide]
	[GitFmtChanges]
	max_age    = 365
	tag_regexp = ^.*$
	file_name  = Changes
	log_format = short

	[OurPkgVersion]
	[GithubMeta]                        ; if github = 1
	[AutoPrereqs]                       ; unless auto_prereqs = 0

	[ReportVersions::Tiny]
	[PodWeaver]
	config_plugin = @Author::RUSSOZ

	; if task_weaver =1
	[TaskWeaver]

	; else (task_weaver = 0)
	[@TestingMania]
	disable = Test::CPAN::Changes, SynopsisTests
	[Test::Pod::No404]

	; endif

	[Twitter]
	tweet_url = http://search.cpan.org/~{{$AUTHOR_LC}}/{{$DIST}}
	hash_tags = #perl #cpan             ; plus tags in twitter_tags
	url_shortener = TinyURL

	[Signature]                         ; if signature = 1

=head1 USAGE

Just put C<[@Author::RUSSOZ]> in your F<dist.ini>. You can supply the following
options:

=over 4

=item *

auto_prereqs

Whether the module will use C<AutoPrereqs> or not. Default = 1.

=item *

github

If using github, enable C<[GithubMeta]>. Default = 1.

=item *

no404

Whether to use C<[Test::Pod::No404]> in the distribution. Default = 0.

=item *

no_twitter

Releases of this module shouldn't be tweeted. Default = 0.

=item *

twitter_tags

Additional hash tags to be used in the release tweet.
The tags C<#cpan> and C<#perl> are always prepended.

=item *

signature

Whether to GPG sign the module or not. Default = 1.

=item *

task_weaver

Set to 1 if this is a C<Task::> distribution. It will enable C<[TaskWeaver]>
while disabling C<[PodWeaver]> and all release tests. Default = 0.

=back

=for Pod::Coverage configure

=head1 ACKNOWLEDGMENTS

Much of the first implementation was shamelessly copied from
L<Dist::Zilla::PluginBundle::Author::DOHERTY>.

=head1 SEE ALSO

Please see those modules/websites for more information related to this module.

=over 4

=item *

L<C<L<Dist::Zilla>>|C<L<Dist::Zilla>>>

=back

=for :stopwords cpan testmatrix url annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata placeholders

=head1 SUPPORT

=head2 Perldoc

You can find documentation for this module with the perldoc command.

  perldoc Dist::Zilla::PluginBundle::Author::RUSSOZ

=head2 Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

=over 4

=item *

Search CPAN

The default CPAN search engine, useful to view POD in HTML format.

L<http://search.cpan.org/dist/Dist-Zilla-PluginBundle-Author-RUSSOZ>

=item *

AnnoCPAN

The AnnoCPAN is a website that allows community annonations of Perl module documentation.

L<http://annocpan.org/dist/Dist-Zilla-PluginBundle-Author-RUSSOZ>

=item *

CPAN Ratings

The CPAN Ratings is a website that allows community ratings and reviews of Perl modules.

L<http://cpanratings.perl.org/d/Dist-Zilla-PluginBundle-Author-RUSSOZ>

=item *

CPAN Forum

The CPAN Forum is a web forum for discussing Perl modules.

L<http://cpanforum.com/dist/Dist-Zilla-PluginBundle-Author-RUSSOZ>

=item *

CPANTS

The CPANTS is a website that analyzes the Kwalitee ( code metrics ) of a distribution.

L<http://cpants.perl.org/dist/overview/Dist-Zilla-PluginBundle-Author-RUSSOZ>

=item *

CPAN Testers

The CPAN Testers is a network of smokers who run automated tests on uploaded CPAN distributions.

L<http://www.cpantesters.org/distro/D/Dist-Zilla-PluginBundle-Author-RUSSOZ>

=item *

CPAN Testers Matrix

The CPAN Testers Matrix is a website that provides a visual way to determine what Perls/platforms PASSed for a distribution.

L<http://matrix.cpantesters.org/?dist=Dist-Zilla-PluginBundle-Author-RUSSOZ>

=back

=head2 Email

You can email the author of this module at C<RUSSOZ at cpan.org> asking for help with any problems you have.

=head2 Internet Relay Chat

You can get live help by using IRC ( Internet Relay Chat ). If you don't know what IRC is,
please read this excellent guide: L<http://en.wikipedia.org/wiki/Internet_Relay_Chat>. Please
be courteous and patient when talking to us, as we might be busy or sleeping! You can join
those networks/channels and get help:

=over 4

=item *

irc.perl.org

You can connect to the server at 'irc.perl.org' and join this channel: #sao-paulo.pm then talk to this person for help: russoz.

=back

=head2 Bugs / Feature Requests

Please report any bugs or feature requests by email to C<bug-dist-zilla-pluginbundle-author-russoz at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dist-Zilla-PluginBundle-Author-RUSSOZ>. You will be automatically notified of any
progress on the request by the system.

=head2 Source Code

The code is open to the world, and available for you to hack on. Please feel free to browse it and play
with it, or whatever. If you want to contribute patches, please send me a diff or prod me to pull
from your repository :)

L<http://github.com/russoz/Dist-Zilla-PluginBundle-Author-RUSSOZ>

  git clone http://github.com/russoz/Dist-Zilla-PluginBundle-Author-RUSSOZ

=head1 AUTHOR

Alexei Znamensky <russoz@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Alexei Znamensky.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT
WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER
PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME
THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE
TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE
SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.

=cut


__END__


