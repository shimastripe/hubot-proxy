{Robot,Adapter,TextMessage,User} = require.main.require 'hubot'
SlackBot = require 'hubot-slack/src/bot'
url = require 'url'
CHATBOT_URL = process.env.CHATBOT_URL
PROXYCHATBOT_URL = process.env.PROXYCHATBOT_URL

class ChatBotAdapter extends SlackBot

  constructor: (@robot, @options) ->
    super @robot, @options
    @robot.logger.debug "ChatBotAdapter Constructor"

  send: (envelope, messages...) ->
    return @robot.logger.error "process.env.PROXYCHATBOT_URL is required." unless PROXYCHATBOT_URL

    @robot.logger.debug "Send messages to ProxyChatBot."
    data = JSON.stringify { user_id: envelope.user.id, room: envelope.room, id: envelope.message.id, text: messages.join('\n') }
    @robot.http(url.resolve(PROXYCHATBOT_URL, 'proxy/messages'))
    .header('Content-Type', 'application/json')
    .post(data) (err) =>
      return @robot.logger.error(err) if err?

  reply: (envelope, messages...) ->
    return @robot.logger.error "process.env.PROXYCHATBOT_URL is required." unless PROXYCHATBOT_URL

    @robot.logger.debug "Reply messages to ProxyChatBot."
    data = JSON.stringify { user_id: envelope.user.id, room: envelope.room, id: envelope.message.id, text: messages.join('\n') }
    @robot.http(url.resolve(PROXYCHATBOT_URL, 'proxy/messages'))
    .header('Content-Type', 'application/json')
    .post(data) (err) =>
      return @robot.logger.error(err) if err?

  run: ->
    @robot.router.post '/chatbot/messages', (req, res) =>
      @robot.logger.debug "Receive messages to ProxyChatBot."
      {message, @self} = req.body
      @message message
      res.end ""
    @emit "connected"

class ProxyChatBotAdapter extends SlackBot

  constructor: (@robot, @options) ->
    super @robot, @options
    @robot.logger.debug "ProxyChatBotAdapter Constructor"

  run: ->
    @robot.router.post '/proxy/messages', (req, res) =>
      @robot.logger.debug "Receive messages from slack."
      {user_id, room, id, text} = req.body
      user = @robot.brain.userForId user_id, room: room
      # @receive new TextMessage(user, text, "messageId")
      @receive new TextMessage(user, text, id)
      res.end ""
    super()

  ###
  Message received from Slack
  ###
  message: (messages) =>
    return @robot.logger.error "process.env.CHATBOT_URL is required." unless CHATBOT_URL

    @robot.logger.debug "Send messages to ChatBot."
    data = JSON.stringify { message: messages, self: @self }
    @robot.http(url.resolve(CHATBOT_URL, 'chatbot/messages'))
    .header('Content-Type', 'application/json')
    .post(data) (err) =>
      return @robot.logger.error(err) if err?

exports.use = (robot) ->
  switch process.env.HUBOT_PROXY_MODE
    when "chat" then new ChatBotAdapter robot, token: process.env.HUBOT_SLACK_TOKEN
    when "proxy" then new ProxyChatBotAdapter robot, token: process.env.HUBOT_SLACK_TOKEN
    else new SlackBot robot, token: process.env.HUBOT_SLACK_TOKEN
