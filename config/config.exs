import Config

# Common compile-time app env

config :tesla, adapter: Tesla.Adapter.Gun

config :tester, :flows, %{
  default_flow: %{
    interval: 60000,
    auth: %{
      base_url: "https://auth.vality.dev",
      realm: "external",
      user: "user",
      password: "password"
    },
    payment_api: %{
      base_url: "https://api.vality.dev/v2",
      origin: "https://dashboard.vality.dev"
    },
    flow: Tester.Flow.Payment,
    options: %{
      bank_card: %{
        card_number: "4242424242424242",
        exp_date: "03/2055",
        cvv: "123",
        card_holder: "Artemius Weinerschnitzel"
      },
      amount: 1000,
      currency: "RUB",
      request_timeout: 15000
    }
  }
}

import_config("#{config_env()}.exs")
