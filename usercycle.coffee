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
        log "Identifying #{userId}"
        g.analytics.identify userId


  #
  # Override createUser
  #
  signupEvent = ->
    settings?.signup?.name or "Signed Up"

  # Wrap createUser so we can modify the callback
  createUser = Accounts.createUser

  if Meteor.isClient
    # Send Signed Up event to segment if a user was created
    trackSignup = (error) ->
      unless error
        user = Meteor.user()

        log "Identifying #{user._id}"
        g.analytics.identify user._id,
          email: user.emails?[0]?.address
          createdAt: new Date()

        log "Tracking #{signupEvent()} for #{user._id}"
        g.analytics.track signupEvent()

    Accounts.createUser = ->
      args = _.values arguments
      callback = args[args.length-1]

      if _.isFunction callback
        args[args.length-1] = (error) ->
          trackSignup error
          callback error
      else
        args.push (error) ->
          trackSignup error

      createUser.apply @, args

  else if Meteor.isServer
    Accounts.createUser = ->
      userId = createUser.apply @, _.values(arguments)
      log "Tracking #{signupEvent()} for #{userId}"
      g.analytics.track
        userId: userId
        event: signupEvent()
        properties:
          user:
            userId: userId
            email: options?.email
            createdAt: new Date()
      userId


  # Itegration with IR
  Router.onRun ->
    name = @route.getName()
    retentionRoutes = _.compact _.flatten [settings?.retention?.routes]
    if Meteor.userId() and _.contains retentionRoutes, name
      eventName = settings?.retention?.name or name
      log "Tracking #{eventName} for #{Meteor.userId()}"
      g.analytics.track eventName
    @next()
