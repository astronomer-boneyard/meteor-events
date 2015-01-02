Meteor.startup ->

  settings = Meteor.settings?.public?.usercycle

  if settings.segment
    analytics.load settings.segment.writeKey
  else
    throw new Error "Your Segment write key is not defined. Did you forget the --settings flag?"


  if Meteor.isClient

    # Debug logger
    log = (msg) ->
      if settings?.debug
        console.log "Usercycle: " + msg


    # Go ahead and identify if a user is already logged in or logs in
    Tracker.autorun ->
      userId = Meteor.userId()
      if userId
        analytics.identify userId
        log "Identified #{userId}"


    # Send Signed Up event to segment if a user was created
    trackSignup = (error) ->
      unless error
        user = Meteor.user()

        analytics.identify user._id,
          email: user.emails?[0]?.address
          createdAt: new Date()
        log "Identified #{user._id}"

        eventName = settings?.signup?.name or "Signed Up"
        analytics.track eventName
        log "Tracked #{eventName}"

    # Wrap createUser so we can modify the callback
    createUser = Accounts.createUser
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


    # Itegration with IR
    Router.onRun ->
      name = @route.getName()
      retentionRoutes = _.compact _.flatten [settings?.retention?.routes]
      if _.contains retentionRoutes, name
        eventName = settings?.retention?.name or name
        analytics.track eventName
        log "Tracked #{eventName}"
      @next()
