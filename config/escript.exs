import Config

config :tester, :start_workers, false

config :logger, backends: [Ink]

config :logger, Ink,
  name: "Tester",
  level: :debug
