require './shotaclass'

prepare

bot = Discordrb::Bot.new $info["user"].chomp, $info["pass"].chomp

bot.message(starting_with: "#{$info["prefix"]}threaddump") do |event|
  drop_thread(event)
end

bot.message(starting_with: "#{$info["prefix"]}staff") do |event|
  returnstaff(event)
end

bot.message(starting_with: "#{$info["prefix"]}gelbooru") do |event|
  randomGelbooru(event)
end

bot.message(starting_with: "#{$info["prefix"]}danbooru") do |event|
  randomDanbooru(event)
end

bot.message(starting_with: "#{$info["prefix"]}help") do |event|
  help(event)
end

bot.message(starting_with: "#{$info["prefix"]}massmention") do |event|
  if event.author.permission?(:kick_members, event.server, event.channel)
    massmention(event)
  else
    event.respond("You arent allowed to do that! >:c")
  end
end

bot.message(starting_with: "#{$info["prefix"]}masspm") do |event|
  if event.author.permission?(:kick_members, event.server, event.channel)
    event.respond mass_pm(event)
  else
    event.respond("You arent allowed to do that! >:c")
  end
end

bot.message(starting_with: "#{$info["prefix"]}mimic") do |event|
  if event.author.permission?(:kick_members, event.server, event.channel)
    mimic(event)
  else
    event.respond("You arent allowed to do that! >:c")
  end
end

bot.message(starting_with: "#{$info["prefix"]}rape") do |event|
  event.respond "_Holds down and cums inside #{event.message.mentions[0].mention}_"
end

bot.message(starting_with: "#{$info["prefix"]}triggered") do |event|
  event.respond("http://puu.sh/mSpsT/1cd32bc004.jpg")
end

bot.message(starting_with: "#{$info["prefix"]}retard") do |event|
  event.respond "https://u.pomf.is/hfjsmj.gif"
end

bot.message(starting_with: "#{$info["prefix"]}doit") do |event|
  event.respond "https://u.pomf.is/bgqhef.gif"
end

bot.message(starting_with: "#{$info["prefix"]}cat") do |event|
  event.respond randomCat
end

bot.message(starting_with: "#{$info["prefix"]}mrpython") do |event|
  event.respond getrandompythons
end

bot.message(starting_with: "#{$info["prefix"]}coinflip") do |event|
  event.respond coinflip
end

bot.message(starting_with: "#{$info["prefix"]}cute") do |event|
  event.respond "https://u.pomf.is/fqbkom.png"
end

bot.message(starting_with: "#{$info["prefix"]}love") do |event|
  event.respond "https://www.youtube.com/watch?v=bI9hgp32-f0"
end

bot.message(starting_with: "#{$info["prefix"]}caps") do |event|
  event.respond "https://u.pomf.is/rkpzpj.jpg"
end

bot.message(starting_with: "#{$info["prefix"]}8ball") do |event|
  event.respond z8ball
end

bot.message() do |event|
  catchallevent(event)
end


#bot.message(starting_with: "#{$info["prefix"]}watchthread") do |event|
  #watchthread(event, event.author)
#end

bot.run