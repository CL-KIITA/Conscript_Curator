import "package:nyxx/nyxx.dart";
import "package:cron/cron.dart";

import "package:conscript_curator/xlib/sys.dart";
import "package:conscript_curator/curator/ref.dart";


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

