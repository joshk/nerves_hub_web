import Config

# Start all of the applications
config :nerves_hub_www, app: "all"

ssl_dir =
  (System.get_env("NERVES_HUB_CA_DIR") || Path.join([__DIR__, "../test/fixtures/ssl/"]))
  |> Path.expand()

config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20

##
# NervesHubAPI
#
config :nerves_hub_www, NervesHubWeb.API.Endpoint,
  debug_errors: true,
  code_reloader: false,
  check_origin: false,
  watchers: [],
  pubsub_server: NervesHub.PubSub,
  https: [
    port: 4002,
    otp_app: :nerves_hub_www,
    # Enable client SSL
    verify: :verify_peer,
    keyfile: Path.join(ssl_dir, "api.nerves-hub.org-key.pem"),
    certfile: Path.join(ssl_dir, "api.nerves-hub.org.pem"),
    cacertfile: Path.join(ssl_dir, "ca.pem")
  ]

##
# NervesHubDevice
#
config :nerves_hub_www, NervesHubWeb.DeviceEndpoint,
  debug_errors: true,
  code_reloader: false,
  check_origin: false,
  watchers: [],
  https: [
    ip: {0, 0, 0, 0},
    port: 4001,
    otp_app: :nerves_hub_www,
    # Enable client SSL
    # Older versions of OTP 25 may break using using devices
    # that support TLS 1.3 or 1.2 negotiation. To mitigate that
    # potential error, we enforce TLS 1.2. If you're using OTP >= 25.1
    # on all devices, then it is safe to allow TLS 1.3 by removing
    # the versions constraint and setting `certificate_authorities: false`
    # See https://github.com/erlang/otp/issues/6492#issuecomment-1323874205
    #
    # certificate_authorities: false,
    verify: :verify_peer,
    verify_fun: {&NervesHubDevice.SSL.verify_fun/3, nil},
    fail_if_no_peer_cert: true,
    keyfile: Path.join(ssl_dir, "device.nerves-hub.org-key.pem"),
    certfile: Path.join(ssl_dir, "device.nerves-hub.org.pem"),
    cacertfile: Path.join(ssl_dir, "ca.pem")
  ]

##
# NervesHub
#
config :nerves_hub_www, firmware_upload: NervesHub.Firmwares.Upload.File

config :nerves_hub_www, NervesHub.Firmwares.Upload.File,
  enabled: true,
  local_path: Path.expand("tmp/firmware"),
  public_path: "/firmware"

# config :nerves_hub_www, NervesHub.Firmwares.Upload.S3, bucket: System.get_env("S3_BUCKET_NAME")

config :nerves_hub_www, NervesHub.Repo, ssl: false

config :nerves_hub_www, NervesHub.Mailer, adapter: Bamboo.LocalAdapter

##
# NervesHubWWW
#
config :nerves_hub_www, NervesHubWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [npm: ["run", "watch", cd: Path.expand("../assets", __DIR__)]]

config :nerves_hub_www, NervesHubWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/nerves_hub_www_web/views/.*(ex)$},
      ~r{lib/nerves_hub_www_web/templates/.*(eex|md)$},
      ~r{lib/nerves_hube_www_web/live/.*(ex)$}
    ]
  ]
