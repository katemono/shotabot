require 'discordrb'
require "mechanize"
require "nokogiri"
require "open-uri"

$mimicked = []

def help(event)
  if event.author.permission?(:kick_members, event.server, event.channel)
    event.author.pm("admin help")
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
      $mimicked.delete(id)
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
   message+="`**ADMIN** " if user.permission?(:manage_server, event.server, event.channel)
   message+=user.name+"`\n" if user.permission?(:kick_members, event.server, event.channel) && user.bot? != true
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

def drop_thread(url)
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
  if prefix.include? "420chan.org"  
    for x in files
      retarr.push("#{prefix}#{x}")
    end
    files = retarr
  end
  
  messages = []
  message=""
  
  #split into a few messages to avoid rate limiting shit
  for x in files do
    if message.length <= 1000 then
      message+=x+" " 
    else
      messages.push(message)
      message=x+" "
    end
  end
  messages.push(message) unless messages.include? message
  return messages
end

def getrandompythons
  return ((URI.parse('http://tomokochan.me/pythons.txt')).read).split.sample
end

def mass_pm(users, text)
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
  event.respond event.text.sub("~massmention","")
end

def randomGelbooru(tag)
  #wont work often due to anonymous user issues
  url="http://gelbooru.com/index.php?page=dapi&s=post&q=index&limit=20&id=2000000&json=1&tags="+((tag.split).join '+')
  return (JSON.parse(((URI.parse(url)).read)).sample["file_url"]).sub('\/','/')
end

def randomDanbooru(tag)
  url="http://danbooru.donmai.us/posts.json?tags="+((tag.split).join '+~')
  return "http://danbooru.donmai.us"+(JSON.parse(((URI.parse(url)).read)).sample["file_url"])
end

def randomCat
  url="http://random.cat/meow"
  return (JSON.parse(((URI.parse(url)).read))["file"])
end

def catchallevent(event)
  event.send_message event.text if $mimicked.include? event.message.author.id
end