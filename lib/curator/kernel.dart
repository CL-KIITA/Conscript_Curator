import "dart:convert";

import "package:nyxx/nyxx.dart";
import "package:cron/cron.dart";
import "package:week_of_year/week_of_year.dart";
import "package:color/color.dart";
import "package:gsheets/gsheets.dart";

import "package:conscript_curator/xlib/collection.dart";
import "package:conscript_curator/xlib/color.dart";
import "package:conscript_curator/xlib/sys.dart";
import "package:conscript_curator/xys/xys.dart";


class CuratorSecrets {
  final String discordToken;
  final String gSProjectId;
  final String gSPrivateKeyId;
  final String gSPrivateKey;
  final String gSClientEmail;
  final String gSClientId;
  final String gSClientX509CertUrl;

  CuratorSecrets({
    required this.discordToken,
    required this.gSProjectId,
    required this.gSPrivateKeyId,
    required this.gSPrivateKey,
    required this.gSClientEmail,
    required this.gSClientId
    required this.gSClientX509CertUrl});
  CuratorSecrets.fromSrv();
  Map<String, String> get _gSCredentialsTab => <String, String>{
    "type": "service_account",
    "project_id": this.gSProjectId,
    "private_key_id": this.gSPrivateKeyId,
    "private_key": this.gSPrivateKey,
    "client_email": this.gSClientEmail,
    "client_id": this.gSClientId,
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": this.gSClientX509CertUrl}
  String get gSCredentials => json.encode(this._gSCredentialsTab);
  GSheets get gSheets => GSheets(this.gSCredentials);
}

class CuratorConfig {
  final String name;
  final String title;
  final String runOn;
  final Locale locale;
  final Uri homepage;
  final Uri articles;
  final Uri iconPath;
  
  final Snowflake guildId;
  final Snowflake sendChanId;
  final Snowflake staffRoleId;
  
  final String formId;
  final String dbId;
  final String sheetName;
  
  final Schedule cron;
  final Location tz;

  CuratorConfig({
    required this.name,
    required this.title,
    required this.runOn,
    required this.locale,
    required this.homepage,
    required this.articles,
    required this.iconPath,
    required this.guildId,
    required this.sendChanId,
    required this.staffRoleId,
    required this.formId,
    required this.dbId,
    required this.sheetName,
    required this.cron,
    required this.tz});
  CuratorConfig.fromXYS(XYSStore xys): this(
    name: xys.find(group: "General", key: "name", type: "String").valueAs<String>(),
    title: xys.find(group: "General", key: "title", type: "String").valueAs<String>(),
    runOn: xys.find(group: "General", key: "on", type: "String").valueAs<String>(),
    locale: xys.find(group: "General", key: "locale", type: "Locale").valueAs<Locale>(),
    homepage: xys.find(group: "General", key: "homepage", type: "Uri").valueAs<Uri>(),
    articles: xys.find(group: "General", key: "articles", type: "Uri").valueAs<Uri>(),
    iconPath: xys.find(group: "General", key: "icon", type: "Uri").valueAs<Uri>(),
    guildId: xys.find(group: "Discord", key: "guild", type: "Snowflake").valueAs<Snowflake>(),
    sendChanId: xys.find(group: "Discord", key: "example", type: "Snowflake").valueAs<Snowflake>(),
    staffRoleId: xys.find(group: "Discord", key: "staff", type: "Snowflake").valueAs<Snowflake>(),
    formId: xys.find(group: "Spreadsheet", key: "form", type: "String").valueAs<String>(),
    dbId: xys.find(group: "Spreadsheet", key: "db", type: "String").valueAs<String>(),
    sheetName: xys.find(group: "Spreadsheet", key: "name", type: "String").valueAs<String>(),
    cron: xys.find(group: "Chrono", key: "cron", type: "String").valueAs<String>(),
    tz: xys.find(group: "Chrono", key: "tz", type: "TimeZone").valueAs<Location>());
}

class CuratorSystem {
  final CuratorSecrets secrets;
  final CuratorConfig config;
  final NyxxGateway gateway;

  CuratorSystem._(this.secrets, this.config, this.gateway);

 static Future<CuratorSystem> launch({required CuratorSecrets secrets, required CuratorConfig config}) async {
  final gateway = await Nyxx.connectGatewayWithOptions(
    CuratorSystem.apiOptions(secrets, config),
    CuratorSystem.clientOptions(secrets, config));
  return CuratorSystem._(secrets, config, gateway);
}

  static CacheConfig<Never> _largeCacheConfig = CacheConfig<Never>(maxSize: 7500);
  static CacheConfig<Never> _defaultCacheConfig = CacheConfig<Never>(maxSize: 2500);
  static CacheConfig<Never> _smallCacheConfig = CacheConfig<Never>(maxSize: 100);

  static Flags<GatewayIntents> intents = GatewayIntents.guilds | GatewayIntents.guildMassages;
  static String userAgent = "";
  static GatewayApiOptions apiOptions({required CuratorSecrets secrets, required CuratorConfig config}) => GatewayApiOptions(token: secrets.discordToken, userAgent: CuratorSystem.userAgent, intents: CuratorSystem.intents);
  static GatewayClientOptions clientOptions({required CuratorSecrets secrets, required CuratorConfig config}) => GatewayClientOptions();

  DateTime get runAt {
    final int threshold = 5;
    final int interval = 1;
    final DateTime curr = DateTime.now()
      .copyWith(second: 0, millisecond: 0, microsecond: 0);

    final ds = List<Duration>.generate(threshold ~/ interval, (int i) => Duration(minutes: (i + 1)));
     Iterable<DateTime> cand = <DateTime>[curr]
       .followedBy(ds.map<DateTime>((Duration d) => curr.add(d)))
       .followedBy(ds.map<DateTime>((Duration d) => curr.subtract(d)));
    cand.sort();
    return cand.where((DateTime dt) => this.config.cron.shouldRunAt(dt)).first;
  }
}

extension DiscordData on CuratorSystem {
  Future<Guild> get guild => this.gateway.guilds.get(this.config.guildId);
  }
  Future<RoleManager> get roles => this.guild.then<PartialUser>((Guild g) => g.roles);
  Future<PartialRole> get staffRole => this.roles.then<PartialRole>((RoleManager rm) => rm.get(this.config.staffRoleId));
  Future<MemberManager> get members => this.guild.then<MemberManager>((Guild g) => g.members);
  PartialUser get developer => this.gateway.user;
  Future<PartialUser> get botUser => this.users.fetchCurrentUser();
  Future<PartialUser> get owner => this.guild.then<PartialUser>((Guild g) => g.owner);
  Future<List<PartialUser>> staffs => this.members
    .then<List<Member>>((MemberManager mm) => mm.list())
    .then<List<PartialUser>>((List<Member> ms) async {
      final PartialRole staff = await this.staffRole;
      return ms
        .where((Member m) => m.roles.contains(staff))
        .map<PartialUser?>((Member m) => m.user)
        .whereType<PartialUser>();
    });
  Future<List<GuildChannel>> get chans => this.guild.then<PartialUser>((Guild g) => g.fetchChannels());
  Future<GuildChannel> get sendChan => this.chans
    .then<GuildChannel>((List<GuildChannel> cs) => cs.where((GuildChannel c => c.id == this.config.sendChanId)).single);
}

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

extension GSheetsSheets on CuratorSystem {
  Future<Spreadsheet> formSS => this.secrets.gSheets.spreadsheet(this.config.formId);
  Future<Spreadsheet> dbSS => this.secrets.gSheets.spreadsheet(this.config.dbId);
  Future<Worksheet> get formSheet async {
    Spreadsheet ss = await this.formSS;
    return ss.worksheetByIndex(0)!;
  }
  Future<Worksheet> get dbSheet async {
    Spreadsheet ss = await this.dbSS;
    return ss.worksheetByTitle(this.config.sheetName)!;
  }
}