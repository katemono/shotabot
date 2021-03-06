require 'discordrb'
require "mechanize"
require "nokogiri"
require "uri"
require "youtube-dl"
require "open-uri"
#require "net/https"

class Shota
  attr_reader :bot,:info, :mimicked, :pmers, :watchedthreads, :lastpm, :message_stack, :songs, :vbot
  attr_writer :bot,:info, :mimicked, :pmers, :watchedthreads, :lastpm, :message_stack, :songs, :vbot

  def initialize(options)
    @info = JSON.parse(File.open("config", "r").read)
    @bot = Discordrb::Bot.new @info["user"].chomp, @info["pass"].chomp
    @mimicked = []
    @pmers = []
    @songs = []
    @watchedthreads = []
    @message_stack = []
    @vbot = nil
    @lastpm = 0
  end

  def send_messages(chanid,mess)
    self.message_stack.push([chanid, mess])
  end

  def run!
    self.bot.message(starting_with: "#{self.info["prefix"]}joinchan") do |event|
      event.server.channels.each do |chan|
        self.vbot = self.bot.voice_connect(chan) if chan.name == event.text.sub("#{self.info["prefix"]}joinchan ", '')
      end
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}play") do |event|
      options = {
        extract_audio: true,
        audio_format: 'mp3',
        output: "%(title)s.mp3"
      }

      filename = (YoutubeDL.download event.text.sub("#{self.info["prefix"]}play ", ''), options).filename
      self.songs.push filename
      puts self.songs
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}threaddump") do |event|
      drop_thread(event)
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}staff") do |event|
      returnstaff(event)
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}gelbooru") do |event|
      randomGelbooru(event)
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}danbooru") do |event|
      randomDanbooru(event)
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}yandere") do |event|
      randomYandere(event)
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}help") do |event|
      help(event)
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}massmention") do |event|
      if event.author.permission?(:kick_members, event.server, event.channel) or event.author.id == 101808947706482688
        massmention(event)
      else
        self.send_messages(event.channel.id,"You arent allowed to do that! >:c")
      end
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}masspm") do |event|
      if event.author.permission?(:kick_members, event.server, event.channel) or event.author.id == 101808947706482688
        self.send_messages(event.channel.id,mass_pm(event))
      else
        self.send_messages(event.channel.id,"You arent allowed to do that! >:c")
      end
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}mimic") do |event|
      if event.author.permission?(:kick_members, event.server, event.channel)
        mimic(event)
      else
        self.send_messages(event.channel.id,"You arent allowed to do that! >:c")
      end
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}rape") do |event|
      self.send_messages(event.channel.id,"_Holds down and cums inside #{event.message.mentions[0].mention}_")
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}triggered") do |event|
      self.send_messages(event.channel.id,"http://i.imgur.com/wnIaRyJ.gif ,faggot")
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}retard") do |event|
      self.send_messages(event.channel.id, "https://u.pomf.is/hfjsmj.gif")
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}doit") do |event|
      self.send_messages(event.channel.id, "https://u.pomf.is/bgqhef.gif")
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}cat") do |event|
      self.send_messages(event.channel.id, randomCat)
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}mrpython") do |event|
      self.send_messages(event.channel.id, getrandompythons)
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}coinflip") do |event|
      self.send_messages(event.channel.id, coinflip)
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}cute") do |event|
      self.send_messages(event.channel.id, "https://u.pomf.is/fqbkom.png")
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}love") do |event|
      self.send_messages(event.channel.id, "https://www.youtube.com/watch?v=bI9hgp32-f0")
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}caps") do |event|
      self.send_messages(event.channel.id, "https://u.pomf.is/rkpzpj.jpg")
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}8ball") do |event|
      self.send_messages(event.channel.id, z8ball)
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}join") do |event|
      self.bot.join(event.text.sub("#{self.info["prefix"]}join ", ''))
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}kick") do |event|
      if event.author.permission?(:kick_members, event.server, event.channel)
        event.server.kick(event.message.mentions[0])
        self.send_messages(event.channel.id,"kicked #{event.message.mentions[0].id}")
      else
        self.send_messages(event.channel.id,"You arent allowed to do that! >:c")
      end
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}id") do |event|
      self.send_messages(event.channel.id,event.message.mentions[0].id)
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}unban") do |event|
      if event.author.permission?(:ban_members, event.server, event.channel)
        id = ((event.text).sub "#{self.info["prefix"]}unban ", "").to_i
        event.server.unban(self.bot.user(id))
        self.send_messages(event.channel.id,"unbaned #{id}")
      else
        self.send_messages(event.channel.id,"You arent allowed to do that! >:c")
      end
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}ban") do |event|
      if event.author.permission?(:ban_members, event.server, event.channel)
        event.server.ban(event.message.mentions[0])
        self.send_messages(event.channel.id,"banned #{event.message.mentions[0].id}")
      else
        self.send_messages(event.channel.id,"You arent allowed to do that! >:c")
      end
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}avatar") do |event|
      self.send_messages(event.channel.id, event.message.mentions[0].avatar_url)
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}pmmentions") do |event|
      pmmentions(event)
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}lmgtfy") do |event|
      imgtfy(event)
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}murderer") do |event|
      #chanid,mess
      self.send_messages(event.channel.id,"_throws red paint on #{event.message.mentions[0].mention}_ \n https://www.youtube.com/watch?v=2w7TCmJUD7g");
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}about") do |event|
      self.send_messages(event.channel.id, "My owner is #{self.info["owner"]} their website is #{self.info["owners_site"]} you can find my source at https://github.com/katemono/shotabot")
    end

    self.bot.message(containing: ["(╯°□°）╯︵ ┻━┻", "(╯°□°）╯︵ ┻━━┻", "┻━┻︵ノ(°□°ノ）"]) do |event|
      self.send_messages(event.channel.id,"┬─┬ノ( º _ ºノ) careful with the tables please")
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}throw") do |event|
      items = [
      "dildo",
      "gameboy",
      "pen",
      "tv",
      "xbone",
      "controller",
      "burrito",
      "butt plug",
      "saiky",
      "can",
      "pillow",
      "trumpet",
      "guitar"
      ]
      self.send_messages(event.channel.id,"_throws a #{items.sample} at #{event.message.mentions[0].mention}_")
    end

    self.bot.message(starting_with: "#{self.info["prefix"]}cuddle") do |event|
      self.send_messages(event.channel.id,"_picks up saiky and sets them in #{event.message.author.mention}'s lap_")
    end

    self.bot.message(containing: ["┬─┬﻿ ノ( ゜-゜ノ)","┬─┬ノ( º _ ºノ)", "┬───────────────┬﻿ ノ( ゜- ゜ノ)", "┬─────────────┬ ノ(^-^ノ)"]) do |event|
      self.send_messages(event.channel.id," (ﾉಥ益ಥ）ﾉ﻿ ┻━━━━━━━━━━━━━━┻ ")
    end

    self.bot.message(containing: "boot") do |event|
      unless event.channel.id == 110373943822540800
        self.send_messages(event.channel.id,"https://u.pomf.is/awgpeo.jpg")
      end
    end

    self.bot.message(containing: ["short","shirt"]) do |event|
      unless event.channel.id == 110373943822540800
        self.send_messages(event.channel.id,"https://u.pomf.is/gzfkxn.jpg")
      end
    end

    self.bot.message(containing: "dad") do |event|
      unless event.channel.id == 110373943822540800
        self.send_messages(event.channel.id,"Just me and my :two_hearts:daddy:two_hearts:, hanging out I got pretty hungry:eggplant: so I started to pout :disappointed: He asked if I was down :arrow_down:for something yummy :heart_eyes::eggplant: and I asked what and he said he'd give me his :sweat_drops:cummies!:sweat_drops: Yeah! Yeah!:two_hearts::sweat_drops: I drink them!:sweat_drops: I slurp them!:sweat_drops: I swallow them whole:sweat_drops: :heart_eyes: It makes :cupid:daddy:cupid: :blush:happy:blush: so it's my only goal... :two_hearts::sweat_drops::tired_face:Harder daddy! Harder daddy! :tired_face::sweat_drops::two_hearts: 1 cummy:sweat_drops:, 2 cummy:sweat_drops::sweat_drops:, 3 cummy:sweat_drops::sweat_drops::sweat_drops:, 4:sweat_drops::sweat_drops::sweat_drops::sweat_drops: I'm :cupid:daddy's:cupid: :crown:princess :crown:but I'm also a whore! :heart_decoration: He makes me feel squishy:heartpulse:!He makes me feel good:purple_heart:! :cupid::cupid::cupid:He makes me feel everything a little should!~ :cupid::cupid::cupid: :crown::sweat_drops::cupid:Wa-What!:cupid::sweat_drops::crown:")
      end
    end

    #self.bot.message(containing: "lmao") do |event|
    #  sleep 1
    #  self.send_messages(event.channel.id,"ayy")
    #end

    self.bot.message(starting_with: "#{self.info["prefix"]}cummies") do |event|
      atscummies(event)
    end

    self.bot.private_message() do |event|
      if event.text.start_with? "#{self.info["prefix"]}join" or event.text.include? "https://discord.gg/"
        self.bot.join(event.text.sub("#{self.info["prefix"]}join ", ''))
      end
      unless self.lastpm == event.message.author.id
        self.lastpm = event.message.author.id
        help(event)
      end
    end

    self.bot.message() do |event|
      catchallevent(event,bot)
    end


    #self.bot.message(starting_with: "#{self.info["prefix"]}watchthread") do |event|
      #watchthread(event, event.author)
    #end

    self.bot.run
  end

  def pmmentions(event)
    id = event.message.author.id
    if self.pmers.include? id
      self.pmers-=[id]
    else
      self.pmers.push(id)
    end
  end

  def imgtfy(event)
    text = URI.escape(URI.escape(event.text.sub("#{self.info["prefix"]}lmgtfy ", '')), "+");
    self.send_messages(event.channel.id, "http://lmgtfy.com/?q=#{text}")
  end

  def help(event)
    usercmds =
    {
    "danbooru"  => "[tags]\n\tReturns random image based on tags from danbooru",
    "gelbooru"  => "[tags]\n\tReturns random image based on tags from gelbooru",
    "yandere"  => "[tags]\n\tReturns random image based on tags from yandere",
    "help"      => "display this message",
    "8ball"     => "[Question]",
    "coinflip"  => "[call and statement]",
    "mrpython"  => "returns random image of a giant penised fellow",
    "staff"     => "returns a list of all staff",
    "rape"      => "[@user]\n\trapes @mentioned user",
    "threaddump"=> "http://chanurl.com/thread\n\tDumps all images from a chan thread",
    "retard"    => "Displays the image of the retard Sam Hyde",
    "triggered" => "Displays a very triggered sjw",
    "doit"      => "Displays a shia lebouf",
    "cute"      => "Displays a qt showing love",
    "love"      => "explains love",
    "caps"      => "what caps mean to you",
    "join"      => "invite url",
    "pmmentions" => "your mentions will now be pm-ed to you",
    "lmgtfy" => "googles it for you",
    "cat"       => "random cat",
    "avatar"    => "@user",
    "murderer"  => "@user",
    "throw"     => "@user",
    "cummies"   => "@user"
    }
    staffcmds =
    {
    "kick"        => "[@user]",
    "ban"         => "[@user]",
    "unban"         => "[@user]",
    "mimic"       => "[@user]\n\tmimics @mentioned user",
    "masspm"      => "[message]\n\tpms all users on server",
    "massmention" => "[message]\n\tindividually mentions every user on server and displays message."
    }
    message = "**User Commands:**\n"
    usercmds.each_pair do |x,y|
      message+="#{self.info["prefix"]}#{x} #{y}\n"
    end
    message+="\n**Staff Commands:**\n"
    staffcmds.each_pair do |x,y|
      message+="#{self.info["prefix"]}#{x} #{y}\n"
    end
    event.author.pm(message)
  end

  def coinflip
    return ["http://tomokochan.me/tails.png", "http://tomokochan.me/heads.png"].sample
  end

  def mimic(event)
    begin
      id = event.message.mentions[0].id
      if self.mimicked.include? id
        self.mimicked-=[id]
      else
        self.mimicked.push(id)
      end
    rescue
      self.send_messages(event.channel.id, "Please provide valid user in form of @ mention")
    end
    self.send_messages(event.channel.id, "ok")
  end

  def returnstaff(event)
    message = "**Staff is:**\n"
    for user in event.channel.users do
     message+="\t- "+user.name+"\n" if user.permission?(:kick_members, event.server, event.channel) && user.bot? != true
    end
    self.send_messages(event.channel.id,message);
  end

  def z8ball
    return ["It is certain",
    "It is decidedly so",
    "Without a doubt",
    "Yes, definitely",
    "You may rely on it",
    "As I see it, yes",
    "Most likely",
    "Outlook good",
    "Yes",
    "Signs point to yes",
    "Reply hazy try again",
    "Ask again later",
    "Better not tell you now",
    "Cannot predict now",
    "Concentrate and ask again",
    "Don't count on it",
    "My reply is no",
    "My sources say no",
    "Outlook not so good",
    "Very doubtful"].sample+"."
  end

  def scrapthread(url)
    agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

    url = url.chomp.lstrip
    html_doc = Nokogiri::HTML(agent.get(url).body)
    files=[]
    if /:\/\/boards\.4chan\.org/.match(url)
      (html_doc.css('div.file')).each{ |ito| files.push "https:#{ito.css("a")[0]['href']}"}
    elsif /:\/\/7chan\.org/.match(url)
      (html_doc.css('p.file_size')).each{ |ito| files.push "#{ito.css("a")[0]['href']}"}
    elsif /:\/\/boards\.420chan\.org/.match(url)
      (html_doc.css('span.filesize')).each{ |ito| files.push "#{ito.css("a")[0]['href']}"}
    else
      (html_doc.css('p.fileinfo')).each{ |ito| files.push "#{ito.css("a")[0]['href']}"}
    end

    retarr = []
    prefix = (url.split '/')[0..-4].join '/'
    if prefix.include? "420chan.org" or prefix.include? "8ch.net"
      for x in files
        if x.include? "http"
          retarr.push x
        else
          retarr.push("#{prefix}#{x}")
        end
      end
      files = retarr
    end

    return files
  end

  #def watchthread(event,author)
  #  thread = {}
  #  url = event.text.sub("#{$info["prefix"]}watchthread", '')
  #  thread["thread"]=scrapthread(url)
  #  thread["time"] = Time.now
  #  thread["url"]  = url
  #  thread["author"] = author
  #  handlemessages(thread["thread"],event.author,pm = true)
  #  $watchedthreads.push thread
  #end

  def handlemessages(items,event,pm = false)
    message = ""
    messages = []
    for x in items do
      if message.length <= 1000 then
        message+=x+" "
      else
        messages.push(message)
        message=x+" "
      end
    end
    messages.push(message) unless messages.include? message or message == ""
    messages.each do|x|
      if pm == true
        event.pm x
      else
        event.send_message x
      end
      sleep 0.1
    end
  end

  def checkup(x)
    author = x["author"]
    thread = x["thread"]
    url = x["url"]
    newthread = scrapthread(url)
    threadx = newthread - thread
    handlemessages(threadx,author,pm = true)
    return newthread
  end

  def drop_thread(event)
    files=scrapthread(event.text.sub("#{self.info["prefix"]}threaddump", ''))
    handlemessages(files,event)
  end

  def getrandompythons
    return ((URI.parse('http://tomokochan.me/pythons.txt')).read).split.sample
  end

  def mass_pm(event)
    users = event.channel.users
    text = event.text.sub("#{self.info["prefix"]}masspm", '')
    for user in users do
      #spit out nasty error if you pm bot
      user.pm(text) unless user.bot?
      sleep 0.1
    end
    return "Done!"
  end

  def atscummies(event)
    user = event.message.mentions[0].mention
    self.send_messages(event.channel.id,"Just me and my :two_hearts:#{user}:two_hearts:, hanging out I got pretty hungry:eggplant: so I started to pout :disappointed: He asked if I was down :arrow_down:for something yummy :heart_eyes::eggplant: and I asked what and he said he'd give me his :sweat_drops:cummies!:sweat_drops: Yeah! Yeah!:two_hearts::sweat_drops: I drink them!:sweat_drops: I slurp them!:sweat_drops: I swallow them whole:sweat_drops: :heart_eyes: It makes :cupid:#{user}:cupid: :blush:happy:blush: so it's my only goal... :two_hearts::sweat_drops::tired_face:Harder #{user}! Harder #{user}! :tired_face::sweat_drops::two_hearts: 1 cummy:sweat_drops:, 2 cummy:sweat_drops::sweat_drops:, 3 cummy:sweat_drops::sweat_drops::sweat_drops:, 4:sweat_drops::sweat_drops::sweat_drops::sweat_drops: I'm :cupid:#{user}'s:cupid: :crown:princess :crown:but I'm also a whore! :heart_decoration: He makes me feel squishy:heartpulse:!He makes me feel good:purple_heart:! :cupid::cupid::cupid:He makes me feel everything a little should!~ :cupid::cupid::cupid: :crown::sweat_drops::cupid:Wa-What!:cupid::sweat_drops::crown:")
  end

  def massmention(event)
    message=""
    messages = []
    for user in event.channel.users do
      if message.length <= 1000
        message+="#{user.mention} "
      else
        messages.push(message)
        message="#{user.mention} "
      end
    end
    messages.push(message) unless messages.include? message
    messages.each do|x|
      self.send_messages(event.channel.id,x)
      sleep 0.1
    end
    self.send_messages(event.channel.id, event.text.sub("#{self.info["prefix"]}massmention",""))
  end

  def randomGelbooru(event)
    #wont work often due to anonymous user issues
    tag = event.text.sub("#{self.info["prefix"]}gelbooru","")
    url="http://gelbooru.com/index.php?page=dapi&s=post&q=index&limit=20&id=2000000&json=1&tags="+((tag.split).join '+')
    #event.respond (JSON.parse(((URI.parse(url)).read)).sample["file_url"]).sub('\/','/')
    #tag= (event.text.sub("#{self.info["prefix"]}yandere","").split).join("+")
    agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
    html_doc = agent.get(url)
    self.send_messages(event.channel.id, JSON.parse(html_doc.body).sample["file_url"])
  end

  def randomYandere(event)
    tag= (event.text.sub("#{self.info["prefix"]}yandere","").split).join("+")
    agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
    html_doc = agent.get("https://yande.re/post.json?limit=200&tags="+tag)
    self.send_messages(event.channel.id, JSON.parse(html_doc.body).sample["file_url"])
  end

  def randomDanbooru(event)
    tag = event.text.sub("#{self.info["prefix"]}danbooru","")
    url="http://danbooru.donmai.us/posts.json?tags=#{((tag.split).join '+~')}"
    self.send_messages(event.channel.id, "http://danbooru.donmai.us"+(JSON.parse(((URI.parse(url)).read)).sample["file_url"]))
  end

  def randomCat
    url="http://random.cat/meow"
    return (JSON.parse(((URI.parse(url)).read))["file"])
  end

  def catchallevent(event,bot)
    event.message.mentions.each do |mention|
      mention.pm("mentioned by #{event.author.username}:\n #{event.text}") if self.pmers.include? mention.id
    end
    event.send_message event.text if self.mimicked.include? event.message.author.id
    self.bot.game=self.info["prefix"]+"help for help"
  end

end
