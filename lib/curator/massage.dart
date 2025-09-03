import "package:nyxx/nyxx.dart";
import "package:week_of_year/week_of_year.dart";
import "package:color/color.dart";

import "package:conscript_curator/xlib/collection.dart";
import "package:conscript_curator/xlib/color.dart";
import "package:conscript_curator/curator/ref.dart";
import "package:conscript_curator/curator/kernel.dart";

extension MassageBuildersSettings on CuratorSystem　{
  final bool get hasPostImage => false;
  final bool get hasPostThumb = true;
  final bool get hasPostFooter => true;
}

extension MassageBuilders on CuratorSystem {
  String get postWeekString {
    final DateTime dt = this.runAt;
    final String ys = (dt.year % 100).toString().padLeft(2, "0");
    final String ws = dt.weekOfYear.toString().padLeft(2, " ")
    return "ʻ$ys年 $ws週";
  }
  String get postTitle => "${this.config.title} (${this.postWeekString})";
  EmbedFieldBuilder get postFieldExample => EmbedFieldBuilder(name: "", value: "", isInline: true);
  EmbedFieldBuilder? get postFieldTranslated => 
  EmbedFieldBuilder(name: "", value: "", isInline: true);
  List<EmbedFieldBuilder> get postFields {
    EmbedFieldBuilder f1 = this.postFieldExample;
    EmbedFieldBuilder? f2 = this.postFieldTranslated;
    if (f2 != null) {
      return <EmbedFieldBuilder>[f1, f2];
    } else {
      return <EmbedFieldBuilder>[f1];
    }
  }
  EmbedFooterBuilder? get postFooter => this.hasPostFooter ? EmbedFooterBuilder(text: this.config.title, iconUrl: this.config.iconPath) : null;
  List<Color> get postColorCandidates => <Color>[];
  DiscordColor get postColor => this.postColorCandidates.sublistCyclic(this.runAt.month - 1, DateTime.daysPerWeek)[this.runAt.weekday - 1];
  EmbedThumbnailBuilder? get postThumb => this.hasPostThumb ? EmbedThumbnailBuilder(url: this.config.iconPath) : null;
  EmbedImageBuilder? get postImage => this.hasPostImage ? EmbedImageBuilder(url: this.config.iconPath) : null;
  EmbedAuthorBuilder get postAuthor => EmbedAuthorBuilder(name: this.config.name, url: this.config.homepage, iconUri: this.config.iconPath);
  EmbedBuilder get postEmbed => EmbedBuilder(title: this.postTitle, description: "", url: this.config.articles, timestamp: this.runAt, color: this.postColor, footer: this.postFooter, image: this.postImage, thumbnail: this.postThumb, fields: this.postFields);
  MessageBuilder get postMassage => MessageBuilder(embeds: this.postEmbed);
}