init = ->
  console.log "INIT363"
  gameScreen = document.getElementById("gameScreen")
  startScreen = document.getElementById("startScreen")
  startGameBtn = document.getElementById("startGameBtn")
  highScore = document.getElementById("highScore")

  blocks = [
    "happy"
    "fire"
    "cog"
    "pacman"
    "skeletor"
    "sun-fill"
    "bomb"
    "neutral"
    "frustrated"
  ]

  endymenGame =
    els:
      table: document.getElementById("table")
      score: document.getElementById("score")
      level: document.getElementById("level")
      moves: document.getElementById("moves")

    stats:
      size:
        x:12
        y:9
      level: 0
      score: 0
      moves: 0
      items: []

    buildTable: ->
      that = @
      arr = @stats.items
      arr.forEach (row, y)->
        tr = document.createElement("div")
        row.forEach (item, x)->
          td = document.createElement("span")
          iconTd = document.createElement("span")
          td.addEventListener "click", -> that.startSearch x,y
          td.click = -> that.startSearch x,y
          td.appendChild iconTd
          tr.appendChild td
          that.setTd td, item

        that.els.table.appendChild tr


    setTd: (td, type)->
      icon = blocks[type]
      iconTd = td.childNodes[0]
      td.className = "color-"+icon
      iconTd.className = " icon-"+icon
      td


    initRandomFields: ->
      y = @stats.size.y
      arr = @stats.items = []
      while y--
        x = @stats.size.x
        arr[y] = []
        while x--
          val = Math.round Math.random()*2
          arr[y][x] = val

    start: ->
      startScreen.classList.add "hidden"
      gameScreen.classList.remove "hidden"
      @stats.moves = 120
      @stats.score = 0
      @stats.level = 7
      @initRandomFields()
      @buildTable()

    it: 0
    found: 0
    
    startSearch:(x,y)->
      if @stats.moves>0
        @stats.moves--
        @findNext x,y

    findNext: (x, y)->
      @it++
      a = @stats.items
      col = a[y][x]
      @found++
      a[y][x]= "x"

      if a[y-1]?[x]==col then @findNext x,y-1
      if a[y+1]?[x]==col then @findNext x,y+1
      if a[y][x-1]? && a[y][x-1]==col then @findNext x-1,y
      if a[y][x+1]? && a[y][x+1]==col then @findNext x+1,y
      
      if @it==1
        @updateStats(@found+1, col)
        @dropDown()
        @found = 0
      @stats.items = a
      @it--

    getRndColor:->
      range = @stats.level+2
      max = 10#bgStyle.length
      if range>=max then range = max
      Math.floor Math.random()*range

    updateStats: (n, col)->
      bonus = if col<3 then 20 else 60*col
      score = (n*n*bonus)
      bonMoves = if col>2 then col-2 else 0
      moves =
        if score>1000 then 1
        else if score>10000 then 5
        else if score>50000 then 10
        else if score>100000 then 15
        else 0
      @stats.moves+= moves+bonMoves
      @stats.level += 1 if (@stats.score/(2000*(@stats.level+1)))>@stats.level
      @stats.score += score
      @els.moves.innerHTML = @stats.moves
      @els.level.innerHTML = @stats.level
      @els.score.innerHTML = @stats.score

    dropDown: ->
      a = @stats.items
      h = a.length
      w = a[h-1].length

      for v, x in a[h-1]
        hh = h
        dropDowns = 0
        while hh--
          if a[hh][x]=="x" then dropDowns++
          else if dropDowns>0
            trgPos = hh+dropDowns
            td = @els.table.childNodes[trgPos].childNodes[x]
            val = a[hh][x]
            a[trgPos][x] = val
            c.l "drop: ",x,hh
            @setTd td, val, true
            #@els.table.childNodes[trgPos].childNodes[x] = td
        hh = 0

        while dropDowns--
          td = @els.table.childNodes[dropDowns].childNodes[x]
          val = @getRndColor()
          a[dropDowns][x] = val
          @setTd td, val, true


  ## Start game
  startGameBtn.addEventListener "click", ->endymenGame.start()
  endymenGame.start()
  window.gg = endymenGame
window.onload = ->
  #gamepad events
  window.ctrl = {}
  eventIO = io.connect('http://localhost:3000/eventRouter')
  eventIO.on "ctrl", (v)-> window.ctrl[v]()

  #keyboard events
  document.addEventListener "keyup", (e)->
    key = e.keyCode
    #c.l key
    evt = e ? e:window.event
    if evt.stopPropagation then evt.stopPropagation()
    if evt.cancelBubble!=null then evt.cancelBubble = true
    action =
      if key==37 then "left"
      else if key==38 then "up"
      else if key==39 then "right"
      else if key==40 then "down"
      else if key==13 then "enter"
      else if key==32 then "back"
    window.ctrl[action]?()

  init()

