use Mix.Config

config :ex_aws,
  region: "${AWS_REGION}"

config :nerves_hub_web_core, NervesHubWebCore.Scheduler,
  global: true,
  jobs: [
    garbage_collect_firmware: [
      schedule: "*/15 * * * *",
      task: {NervesHubWebCore.Firmwares.GC, :run, []}
    ],
    digest_firmware_transfers: [
      schedule: "*/30 * * * *",
      task: {NervesHubWebCore.Firmwares.Transfer.S3Ingress, :run, []}
    ]
  ]

config :nerves_hub_web_core, firmware_upload: NervesHubWebCore.Firmwares.Upload.S3
config :nerves_hub_web_core, NervesHubWebCore.Firmwares.Upload.S3, bucket: "${S3_BUCKET_NAME}"

config :nerves_hub_web_core, NervesHubWebCore.Firmwares.Transfer.S3Ingress,
  bucket: "${S3_LOG_BUCKET_NAME}"

config :nerves_hub_web_core, NervesHubWebCore.CertificateAuthority,
  host: "nerves-hub-ca.local",
  port: 8443,
  ssl: [
    keyfile: "/etc/ssl/ca-client-key.pem",
    certfile: "/etc/ssl/ca-client.pem",
    cacertfile: "/etc/ssl/ca.pem",
    server_name_indication: 'ca.nerves-hub.org'
  ]
