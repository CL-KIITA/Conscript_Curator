import "dart:convert";

import "package:nyxx/nyxx.dart";
import "package:cron/cron.dart";

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