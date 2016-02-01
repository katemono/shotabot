require './shotaclass'

userinfo=[]
File.open("config", "r") do |f|
  f.each_line do |line|
    userinfo.push line
  end
end

bot = Discordrb::Bot.new userinfo[0].chomp, userinfo[1].chomp

bot.message(starting_with: "~coinflip") do |event|
  event.respond coinflip
end

bot.message(starting_with: "~8ball") do |event|
  event.respond z8ball
end

bot.message(starting_with: "~massmention") do |event|
  if event.author.permission?(:kick_members, event.server, event.channel)
    massmention(event)
  else
    event.respond("You arent allowed to do that! >:c")
  end
end

bot.message(starting_with: "~triggered") do |event|
  event.respond("http://puu.sh/mSpsT/1cd32bc004.jpg")
end

bot.message(starting_with: "~masspm") do |event|
  if event.author.permission?(:kick_members, event.server, event.channel)
    event.respond mass_pm(event.channel.users, event.text.sub('~masspm', ''))
  else
    event.respond("You arent allowed to do that! >:c")
  end
end

bot.message(starting_with: "~threaddump") do |event|
  (drop_thread(event.text.sub("~threaddump", ''))).each do |x| 
    event.send_message(x)
    sleep 1
  end
  event.respond "Done!"
end

bot.message(starting_with: "~staff") do |event|
  returnstaff(event)
end

bot.message() do |event|
  catchallevent(event)
end

bot.message(starting_with: "~mimic") do |event|
  if event.author.permission?(:kick_members, event.server, event.channel)
    mimic(event)
  else
    event.respond("You arent allowed to do that! >:c")
  end
end

bot.message(starting_with: "~gelbooru") do |event|
  event.respond randomGelbooru(event.text.sub("~gelbooru",""));
end

bot.message(starting_with: "~rape") do |event|
  event.respond "_Holds down and cums inside #{event.message.mentions[0].mention}_"
end

bot.message(starting_with: "~cat") do |event|
  event.respond randomCat
end

bot.message(starting_with: "~danbooru") do |event|
  event.respond randomDanbooru(event.text.sub("~gelbooru",""));
end

bot.message(starting_with: "~mrpython") do |event|
  event.respond getrandompythons
end

bot.message(starting_with: "~help") do |event|
  help(event)
end

bot.run