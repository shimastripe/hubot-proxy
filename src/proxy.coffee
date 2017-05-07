{Robot,Adapter,TextMessage,User} = require.main.require 'hubot'
SlackBot = require 'hubot-slack/src/bot'
url = require 'url'
TO_PROXY_URL = process.env.TO_PROXY_URL

class ToProxyBot extends SlackBot

  constructor: (@robot, @options) ->
    super @robot, @options
    @robot.logger.info "ToProxyBot Constructor"

  send: (envelope, messages...) ->
    unless TO_PROXY_URL?
      return robot.logger.warning 'Required TO_PROXY_URL env.'

    @robot.logger.info "Send to proxyChatBot."
    data = JSON.stringify { user_id: envelope.user.id, room: envelope.room, text: messages.join('\n') }
    @robot.http(url.resolve(TO_PROXY_URL, 'proxy/messages'))
    .header('Content-Type', 'application/json')
    .post(data) (err) =>
      return @robot.logger.error(err) if err?

  reply: (envelope, strings...) ->
    unless TO_PROXY_URL?
      return robot.logger.warning 'Required TO_PROXY_URL env.'

    @robot.logger.info "Reply to proxyChatBot."
    data = JSON.stringify { user_id: envelope.user.id, room: envelope.room, text: messages.join('\n') }
    @robot.http(url.resolve(TO_PROXY_URL, 'proxy/messages'))
    .header('Content-Type', 'application/json')
    .post(data) (err) =>
      return @robot.logger.error(err) if err?

class ToSlackBot extends SlackBot

  constructor: (@robot, @options) ->
    super @robot, @options
    @robot.logger.info "ToSlackBot Constructor"

  run: ->
    return @robot.logger.error "No service token provided to Hubot" unless @options.token
    return @robot.logger.error "Invalid service token provided, please follow the upgrade instructions" unless (@options.token.substring(0, 5) in ['xoxb-', 'xoxp-'])

    @robot.router.post '/proxy/messages', (req, res) =>
      {user_id, room, text} = req.body
      user = @robot.brain.userForId user_id, room: room
      @receive new TextMessage(user, text, "messageId")
      res.end ""
    @emit "connected"

exports.use = (robot) ->
  switch process.env.HUBOT_PROXY_MODE
    when "toproxy" then new ToProxyBot robot, token: process.env.HUBOT_SLACK_TOKEN
    when "tochat" then new ToSlackBot robot, token: process.env.HUBOT_SLACK_TOKEN
    else new SlackBot robot, token: process.env.HUBOT_SLACK_TOKEN
