{Robot,Adapter,TextMessage,User} = require.main.require 'hubot'
SlackBot = require 'hubot-slack/src/bot'
url = require 'url'
CHATBOT_URL = process.env.CHATBOT_URL
PROXYCHATBOT_URL = process.env.PROXYCHATBOT_URL

class ToProxyBot extends SlackBot

  constructor: (@robot, @options) ->
    super @robot, @options
    @robot.logger.info "ToProxyBot Constructor"

  send: (envelope, messages...) ->
    return @robot.logger.error "process.env.PROXYCHATBOT_URL is required." unless PROXYCHATBOT_URL

  reply: (envelope, messages...) ->
    return @robot.logger.error "process.env.PROXYCHATBOT_URL is required." unless PROXYCHATBOT_URL

  run: ->
    @robot.router.post '/proxy/messages', (req, res) =>
      {message, @self} = req.body
      @message message
      res.end ""
    @emit "connected"

class ToSlackBot extends SlackBot

  constructor: (@robot, @options) ->
    super @robot, @options
    @robot.logger.info "ToSlackBot Constructor"

  ###
  Message received from Slack
  ###
  message: (message) =>
    return @robot.logger.error "process.env.CHATBOT_URL is required." unless CHATBOT_URL

    data = JSON.stringify { message: message, self: @self }
    @robot.http(url.resolve(CHATBOT_URL, 'proxy/messages'))
    .header('Content-Type', 'application/json')
    .post(data) (err) =>
      return @robot.logger.error(err) if err?

exports.use = (robot) ->
  switch process.env.HUBOT_PROXY_MODE
    when "toproxy" then new ToProxyBot robot, token: process.env.HUBOT_SLACK_TOKEN
    when "tochat" then new ToSlackBot robot, token: process.env.HUBOT_SLACK_TOKEN
    else new SlackBot robot, token: process.env.HUBOT_SLACK_TOKEN
