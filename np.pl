# np.pl
# github.com/stackptr
#
# Colorized now playing script for mpd/mpc.
#
# Use /np to print current song to buffer

use strict;
use warnings;

my $descr = 'Colorized now playing script for mpd';
weechat::register('np', 'byte', '0.1', 'GPL3', $descr, '', '');
weechat::hook_command('np', $descr, '',
"Settings:

Turn on/off color formatting for messages:
  /set plugins.var.perl.np.use_color <on|off>
  Default: On
  
Define colors for messages:
  /set plugins.var.perl.np.color.{title,artist,album,date} <\"color\">
  Defaults:  title - lightmagenta
            artist - blue
             album - lightgreen
              date - yellow

Define format for now playing:
  /set plugins.var.perl.np.format <format>
  \%title\%, \%artist\%, \%album\%, \%date\% in addition to text
  Default: \"\%title\% by \%artist\% from \%album\% (\%date\%)\"


", '', 'start', '');
return weechat::WEECHAT_RC_OK;


sub start {
  
  my $output = "/me is now playing: ";
  
  my %data = (
    "title" => `mpc -f %title% | head -n 1`,
    "artist" =>`mpc -f %artist% | head -n 1`,
    "album" => `mpc -f %album% | head -n 1`,
    "date" => `mpc -f %date% | head -n 1`
  );
  chomp %data;
  
  %data = addColor(\%data) unless weechat::config_get_plugin("use_color") eq "off";
  
  # Todo: Add ability to change foramt
  $output .= $data{"title"}." by ".$data{"artist"}." from ".$data{"album"}." (".$data{"date"}.")";
  
  weechat::command(weechat::current_buffer, $output)
}

sub addColor {
  # Color table to translate names to color codes
  my %color_table = (white => "00", black => "01", darkblue => "02", darkgreen => "03", lightred => "04",
		                 darkred => "05", magenta => "06", orange => "07", yellow => "08", lightgreen => "09",
		                 cyan => "10", lightcyan => "11", lightblue => "12", lightmagenta => "13", gray => "14",
		                 lightgray => 15);
  
  # Make sure colors are either defined or defaults
  weechat::config_set_plugin("color.title", "lightmagenta") if weechat::config_get_plugin("color.title") eq "";
  weechat::config_set_plugin("color.artist", "lightblue") if weechat::config_get_plugin("color.artist") eq "";
  weechat::config_set_plugin("color.album", "lightgreen") if weechat::config_get_plugin("color.album") eq "";
  weechat::config_set_plugin("color.date", "yellow") if weechat::config_get_plugin("color.date") eq "";
  
  # Convert to raw color codes
  my $color_title = "\cC" . $color_table{(weechat::config_get_plugin("color.title"))};
  my $color_artist = "\cC" . $color_table{(weechat::config_get_plugin("color.artist"))};
  my $color_album = "\cC" . $color_table{(weechat::config_get_plugin("color.album"))};
  my $color_date = "\cC" . $color_table{(weechat::config_get_plugin("color.date"))};
  my $reset_color = "\cC00";
  
  return (
    "title" => $color_title.$_[0]{"title"}.$reset_color,
    "artist" => $color_artist.$_[0]{"artist"}.$reset_color,
    "album" => $color_album.$_[0]{"album"}.$reset_color,
    "date" => $color_date.$_[0]{"date"}.$reset_color
  )
}
