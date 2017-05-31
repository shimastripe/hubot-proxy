# hubot-proxy

Hubot adapter for interfacing with ProxyChatBot.

## Installation & Usage

Once you have a hubot created, follow these steps:

```
$ npm install --save git://github.com/shimastripe/hubot-proxy.git

// Set the environment variables specified in Configuration

$ ./bin/hubot -a proxy
```

## Configuration

This adapter uses the following environment variables:

Env variable      | Description                                         | Default |          Required
----------------- | :-------------------------------------------------- | ------: | ----------------:
CHATBOT_URL       | You can specify a webhook URL.                      |         | only ProxyChatBot
PROXYCHATBOT_URL  | You can specify a webhook URL.                      |         |      only ChatBot
HUBOT_PROXY_MODE  | You can specify a bot mode, ChatBot or ProxyChatBot |         |               yes
HUBOT_SLACK_TOKEN | The token that the slack give you                   |         |               yes
