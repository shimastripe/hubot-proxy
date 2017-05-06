{Robot,Adapter,TextMessage,User} = require 'hubot'
SlackBot = require 'hubot-slack/src/bot'

class ToProxyBot extends SlackBot

  constructor: ->
    super
    @robot.logger.info "ToProxyBot Constructor"

  send: (envelope, strings...) ->
    @robot.logger.info "Send"

  reply: (envelope, strings...) ->
    @robot.logger.info "Reply"

class ToSlackBot extends SlackBot

  constructor: ->
    super
    @robot.logger.info "ToSlackBot Constructor"

  run: ->
    @robot.logger.info "Run"
    @emit "connected"
    user = new User 1001, name: 'Proxy User'
    message = new TextMessage user, 'Some Proxy Message', 'MSG-001'
    @robot.receive message

exports.use = (robot) ->
  switch process.env.HUBOT_PROXY_MODE
    when "toproxy" then new ToProxyBot robot, token: process.env.HUBOT_SLACK_TOKEN
    when "tochat" then new ToSlackBot robot, token: process.env.HUBOT_SLACK_TOKEN
    else new SlackBot robot, token: process.env.HUBOT_SLACK_TOKEN
