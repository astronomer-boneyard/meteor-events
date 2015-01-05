Meteor.startup ->

  settings = Meteor.settings?.public?.usercycle

  g = if Meteor.isServer then global else window

  if settings.segment
    g.analytics.load settings.segment.writeKey
  else
    throw new Error "Your Segment write key is not defined. Did you forget the --settings flag?"

  # Debug logger
  log = (msg) ->
    if settings?.debug
      console.log "Usercycle: " + msg


  # Go ahead and identify if a user is already logged in or logs in
  if Meteor.isClient
    Tracker.autorun ->
      userId = Meteor.userId()
      if userId
        g.analytics.identify userId
        log "Identified #{userId}"


  # Send Signed Up event to segment if a user was created
  trackSignup = (error) ->
    unless error
      user = Meteor.user()

      g.analytics.identify user._id,
        email: user.emails?[0]?.address
        createdAt: new Date()
      log "Identified #{user._id}"

      eventName = settings?.signup?.name or "Signed Up"
      g.analytics.track eventName
      log "Tracked #{eventName}"

  # Wrap createUser so we can modify the callback
  createUser = Accounts.createUser
  Accounts.createUser = (options, callback)->
    args = _.values arguments
    if Meteor.isClient
      callback = args[args.length-1]

      if _.isFunction callback
        args[args.length-1] = (error) ->
          trackSignup error
          callback error
      else
        args.push (error) ->
          trackSignup error

    userId = createUser.apply @, args

    if Meteor.isServer
      eventName = settings?.signup?.name or "Signed Up"
      g.analytics.track
        userId: userId
        event: eventName
        properties:
          user:
            userId: userId
            email: options?.email
            createdAt: new Date()
      log "Tracked #{eventName}"

    userId

  # Itegration with IR
  Router.onRun ->
    name = @route.getName()
    retentionRoutes = _.compact _.flatten [settings?.retention?.routes]
    if _.contains retentionRoutes, name
      eventName = settings?.retention?.name or name
      g.analytics.track eventName
      log "Tracked #{eventName}"
    @next()
