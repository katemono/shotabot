require 'discordrb'
require "mechanize"
require "nokogiri"
require "open-uri"

$mimicked = []
$watchedthreads = []
$info={}

def prepare
  $info = JSON.parse(File.open("config", "r").read)
end

def help(event)
  if event.author.permission?(:kick_members, event.server, event.channel)
    event.author.pm("~mimic @mentionuser
~danbooru tags
~cat
~8ball question?
~coinflip
~mrpython
~staff
~threaddump chanthreadurl
~rape @mentionuser
~masspm what to pm
~massmention do a mass mention")
  else 
    event.author.pm("user help")
  end
end

def coinflip
  return ["http://tomokochan.me/tails.png", "http://tomokochan.me/heads.png"].sample
end

def mimic(event)
  begin 
    id = event.message.mentions[0].id
    if $mimicked.include? id
      $mimicked-=[id]
    else
      $mimicked.push(id)
    end
  rescue
    event.respond "Please provide valid user in form of @ mention"
  end
  event.respond "ok"
end

def returnstaff(event)
  message = "Staff is:\n"
  for user in event.channel.users do
   message+="*ADMIN* " if user.permission?(:manage_server, event.server, event.channel)
   message+=user.name+"\n" if user.permission?(:kick_members, event.server, event.channel) && user.bot? != true
  end
  event.send_message(message);
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

  if /:\/\/boards\.4chan\.org/.match(url) do
    (html_doc.css('div.file')).each{ |ito| files.push "https:#{ito.css("a")[0]['href']}"}
  end

  elsif /:\/\/7chan\.org/.match(url) do
    (html_doc.css('p.file_size')).each{ |ito| files.push "#{ito.css("a")[0]['href']}"}
  end

  elsif /:\/\/boards\.420chan\.org/.match(url) do
    (html_doc.css('span.filesize')).each{ |ito| files.push "#{ito.css("a")[0]['href']}"}
  end

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

def watchthread(event)
  thread = {}
  url = event.text.sub("#{$info["prefix"]}watchthread", '')
  thread["thread"]=scrapthread(url)
  thread["time"] = Time.now
  thread["url"]  = url
  thread["author"] = event.author
  handlemessages(thread["thread"],event.author,pm = true)
  $watchedthreads.push thread
end

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
  files=scrapthread(event.text.sub("#{$info["prefix"]}threaddump", ''))
  handlemessages(files,event)
end

def getrandompythons
  return ((URI.parse('http://tomokochan.me/pythons.txt')).read).split.sample
end

def mass_pm(event)
  users = event.channel.users 
  text = event.text.sub("#{$info["prefix"]}masspm", '')
  for user in users do
    #spit out nasty error if you pm bot
    user.pm(text) unless user.bot?
    sleep 0.1 
  end
  return "Done!"
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
    event.send_message(x)
    sleep 0.1
  end
  event.respond event.text.sub("#{$info["prefix"]}massmention","")
end

def randomGelbooru(event)
  #wont work often due to anonymous user issues
  tag = event.text.sub("#{$info["prefix"]}gelbooru","")
  url="http://gelbooru.com/index.php?page=dapi&s=post&q=index&limit=20&id=2000000&json=1&tags="+((tag.split).join '+')
  event.respond (JSON.parse(((URI.parse(url)).read)).sample["file_url"]).sub('\/','/')
end

def randomDanbooru(event)
  tag = event.text.sub("#{$info["prefix"]}gelbooru","")
  url="http://danbooru.donmai.us/posts.json?tags="+((tag.split).join '+~')
  event.respond "http://danbooru.donmai.us"+(JSON.parse(((URI.parse(url)).read)).sample["file_url"])
end

def randomCat
  url="http://random.cat/meow"
  return (JSON.parse(((URI.parse(url)).read))["file"])
end

def catchallevent(event)
  if $watchedthreads.length > 0
    for x in $watchedthreads
      if (Time.now - x["time"]) > 600
        x["thread"] = checkup(x)["thread"]
        x["time"] = Time.now
      end
    end
  end   
  event.send_message event.text if $mimicked.include? event.message.author.id
end
