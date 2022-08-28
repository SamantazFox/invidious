module YoutubeAPI::Clients
  extend self

  # -------------------
  #  Applications
  # -------------------

  enum App
    Browser
    Android
    Android_Music
    Android_Creator
    Android_TV
    IOS
    IOS_Music
    IOS_Creator
    IOS_TV

    def is_android?
      return (self.android? || self.android_music? || self.android_creator? || self.android_tv?)
    end

    def is_ios?
      return (self.ios? || self.ios_music? || self.ios_creator? || self.ios_tv?)
    end
  end

  # List of the various app names and versions.
  #
  # For the sake of simplicity, the regular "Mozilla/5.0" User-Agent
  # is listed as an app below, to reduce the amount of logic required
  # for UA crafting.
  APPS = {
    App::Browser => {
      name:    "Mozilla",
      version: "5.0",
    },
    App::Android => {
      name:    "com.google.android.youtube",
      version: "17.33.42",
    },
    App::Android_Music => {
      name:    "com.google.android.apps.youtube.music",
      version: "5.21.51",
    },
    App::Android_Creator => {
      name:    "com.google.android.apps.youtube.creator",
      version: "22.31.100",
    },
    App::Android_TV => {
      name:    "com.google.android.apps.youtube.unplugged",
      version: "6.32.3",
    },
    App::IOS => {
      name:    "com.google.ios.youtube",
      version: "17.33.2",
    },
    App::IOS_Music => {
      name:    "com.google.ios.youtubemusic",
      version: "5.21",
    },
    App::IOS_Creator => {
      name:    "com.google.ios.ytcreator",
      version: "22.33.101",
    },
    App::IOS_TV => {
      name:    "com.google.ios.youtubeunplugged",
      version: "6.33",
    },
  }

  private APP_LOCALES = [
    "en",
    "en_CA",
    "en_GB",
    "en_US",
    "es",
    "es_ES",
    "fr",
    "fr_BE",
    "fr_FR",
    "hi_IN",
    "ja_JP",
    "pt",
    "pt_BR",
    "pt_PT",
    "zh",
    "zh_CN",
    "zh_HK",
    "zh_SG",
    "zh_TW",
  ]

  APP_LOCALE = APP_LOCALES.sample

  # -------------------
  #  Devices
  # -------------------

  IOS_VERSION_LATEST = [15, 6, 1]
  IOS_BUILD_LATEST   = "19G82"

  IPADOS_VERSION_LATEST = [15, 6, 1]
  IPADOS_BUILD_LATEST   = "19G82"

  private DEVICES_APPLE_IPHONE = [
    "iPhone14,5", # iPhone 13
    "iPhone14,4", # iPhone 13 Mini
    "iPhone14,2", # iPhone 13 Pro
    "iPhone14,3", # iPhone 13 Pro Max
    "iPhone14,6", # iPhone SE (3rd)
  ]

  private DEVICES_APPLE_IPAD = [
    # iPad (9th Gen)
    "iPad12,1",
    "iPad12,2",
    # iPad mini (6th Gen)
    "iPad14,1",
    "iPad14,2",
    # iPad Air (5th Gen)
    "iPad13,16",
    "iPad13,17",
    # iPad Pro 11" (5th Gen)
    "iPad13,4",
    "iPad13,5",
    "iPad13,6",
    "iPad13,7",
    # iPad Pro 12.9" (5th Gen)
    "iPad13,8",
    "iPad13,9",
    "iPad13,10",
    "iPad13,11",
  ]

  # List of currently supported Android version, with their
  # associated SDK version (a.k.a "API level")
  ANDROID_VERSIONS = {
    {api_level: 30_i64, name: "Android 11"},
    {api_level: 31_i64, name: "Android 12"},
    {api_level: 32_i64, name: "Android 12L"},
    {api_level: 33_i64, name: "Android 13"},
  }

  private ANDROID_DEVICES = [
    "SAMSUNG SM-G973U",
    "SM-A205U",
    "SM-A102U",
    "SM-G960U",
    "SM-N960U",
    "LM-Q720",
    "LM-X420",
    "LM-Q710(FGN)",
  ]

  private DESKTOP_DEVICES = [
    "(Macintosh; Intel Mac OS X 10.15",
    "(Macintosh; Intel Mac OS X 10_15_6",
    "(Macintosh; Intel Mac OS X 10_15_7",
    "(Windows NT 6.1; Win64; x64",
    "(Windows NT 10.0; WOW64",
    "(X11; Linux x86_64",
    "(X11; Ubuntu; Linux x86_64",
  ]

  # Select one random device of every type on every startup
  DEVICE_IPAD   = DEVICES_APPLE_IPAD.sample
  DEVICE_IPHONE = DEVICES_APPLE_IPHONE.sample

  VERSION_ANDROID = ANDROID_VERSIONS.sample
  DEVICE_ANDROID  = ANDROID_DEVICES.sample

  DEVICE_DESKTOP = DESKTOP_DEVICES.sample

  # Enumerate for the different types of supported devices
  enum DeviceType
    Desktop
    Android
    Iphone
    Ipad
  end

  # -------------------
  #  Browsers
  # -------------------

  # Edge, desktop-only
  BROWSERS_EDGE = [
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.114 Safari/537.36 Edg/103.0.1264.62",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.134 Safari/537.36 Edg/103.0.1264.71",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.134 Safari/537.36 Edg/103.0.1264.77",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5112.81 Safari/537.36 Edg/104.0.1293.47",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.114 Safari/537.36 Edg/103.0.1264.49",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5112.81 Safari/537.36 Edg/104.0.1293.54",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.64 Safari/537.36 Edg/101.0.1210.53",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5112.102 Safari/537.36 Edg/104.0.1293.63",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.53 Safari/537.36 Edg/103.0.1264.37",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.66 Safari/537.36 Edg/103.0.1264.44",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36 Edg/100.0.1185.44",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.63 Safari/537.36 Edg/102.0.1245.33",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.34 Safari/537.36 Edg/101.0.1210.19",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.54 Safari/537.36 Edg/101.0.1210.39",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.64 Safari/537.36 Edg/101.0.1210.47",
    ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.63 Safari/537.36 Edg/102.0.1245.39",
  ]

  # Firefox, android & desktop
  BROWSERS_FIREFOX = [
    "; rv:91.0) Gecko/20100101 Firefox/91.0",
    "; rv:92.0) Gecko/20100101 Firefox/92.0",
    "; rv:93.0) Gecko/20100101 Firefox/93.0",
    "; rv:94.0) Gecko/20100101 Firefox/94.0",
    "; rv:95.0) Gecko/20100101 Firefox/95.0",
    "; rv:96.0) Gecko/20100101 Firefox/96.0",
    "; rv:97.0) Gecko/20100101 Firefox/97.0",
    "; rv:98.0) Gecko/20100101 Firefox/98.0",
    "; rv:99.0) Gecko/20100101 Firefox/99.0",
    "; rv:100.0) Gecko/20100101 Firefox/100.0",
    "; rv:101.0) Gecko/20100101 Firefox/101.0",
    "; rv:102.0) Gecko/102.0 Firefox/102.0",
    "; rv:103.0) Gecko/103.0 Firefox/103.0",
    "; rv:104.0) Gecko/104.0 Firefox/104.0",
  ]

  # -------------------
  #  UA crafting
  # -------------------

  def get_system_string_browser(device : DeviceType)
    case device
    when .android?
      return "(Linux; #{VERSION_ANDROID[:name]}; Mobile; #{DEVICE_ANDROID}"
    when .desktop?
      return DEVICE_DESKTOP
    when .ipad?
      return "(iPad; CPU OS #{IPADOS_VERSION_LATEST.join('_')} like Mac OS X"
    when .iphone?
      return "(iPhone; CPU iPhone OS #{IOS_VERSION_LATEST.join('_')} like Mac OS X"
    end
  end

  def get_system_string_app(device : DeviceType)
    case device
    when .android?
      return "(Linux; U; #{VERSION_ANDROID[:name]}; #{APP_LOCALE}) gzip"
    when .ipad?
      return "(#{DEVICE_IPAD}; CPU iPadOS #{IPADOS_VERSION_LATEST.join('_')} like Mac OS X; #{APP_LOCALE})"
    when .iphone?
      return "(#{DEVICE_IPHONE}; CPU iOS #{IOS_VERSION_LATEST.join('_')} like Mac OS X; #{APP_LOCALE})"
    else
      raise Exception.new("Invalid App/Device combination.")
    end
  end

  def get_agent_version_browser(device : DeviceType)
    case device
    when .android?
      return BROWSERS_FIREFOX.sample
    when .desktop?
      return (BROWSERS_EDGE + BROWSERS_FIREFOX).sample
    when .iphone?
      return "Version/#{IPADOS_VERSION_LATEST.join('.')} Mobile/#{IPADOS_BUILD_LATEST} Safari/604.1"
    when .ipad?
      return "Version/#{IPADOS_VERSION_LATEST.join('.')} Mobile/#{IPADOS_BUILD_LATEST} Safari/604.1"
    end
  end

  def craft_user_agent(device : DeviceType, app : App) : String
    return String.build do |str|
      str << YT_APPS[app][:name] << '/' << YT_APPS[app][:version] << ' '

      if app.browser?
        str << get_system_string_browser(device)
        str << get_agent_version_browser(device)
      else
        str << get_system_string_app(device)
      end
    end
  end
end
