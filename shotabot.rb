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

bot.message(starting_with: "#{$info["prefix"]}join") do |event|
  bot.join(event.text.sub("#{$info["prefix"]}join ", ''))
end

bot.message(starting_with: "#{$info["prefix"]}kick") do |event|
  if event.author.permission?(:kick_members, event.server, event.channel)
    event.server.kick(event.message.mentions[0])
    event.respond("kicked #{event.message.mentions[0].id}")
  else
    event.respond("You arent allowed to do that! >:c")
  end
end

bot.message(starting_with: "#{$info["prefix"]}id") do |event|
  event.respond(event.message.mentions[0].id)
end

bot.message(starting_with: "#{$info["prefix"]}unban") do |event|
  if event.author.permission?(:ban_members, event.server, event.channel)
    id = ((event.text).sub "#{$info["prefix"]}unban ", "").to_i
    event.server.unban(bot.user(id))
    event.respond("unbaned #{id}")
  else
    event.respond("You arent allowed to do that! >:c")
  end
end

bot.message(starting_with: "#{$info["prefix"]}ban") do |event|
  if event.author.permission?(:ban_members, event.server, event.channel)
    event.server.ban(event.message.mentions[0])
    event.respond("banned #{event.message.mentions[0].id}")
  else
    event.respond("You arent allowed to do that! >:c")
  end
end

bot.message(starting_with: "#{$info["prefix"]}avatar") do |event|
  event.respond event.message.mentions[0].avatar_url
end

bot.message(starting_with: "#{$info["prefix"]}pmmentions") do |event|
  pmmentions(event)
end

bot.message(starting_with: "#{$info["prefix"]}lmgtfy") do |event|
  imgtfy(event)
end

bot.message(starting_with: "#{$info["prefix"]}murderer") do |event|
  event.send_message("_throws red paint on #{event.message.mentions[0].mention}_ \n https://www.youtube.com/watch?v=2w7TCmJUD7g");
end

bot.message(starting_with: "#{$info["prefix"]}about") do |event|
  event.respond "My owner is #{$info["owner"]} their website is #{$info["owners_site"]} you can find my source at https://github.com/katemono/shotabot"
end

bot.message(containing: ["(╯°□°）╯︵ ┻━┻", "(╯°□°）╯︵ ┻━━┻", "┻━┻︵ノ(°□°ノ）"]) do |event|
  event.respond("┬─┬ノ( º _ ºノ) careful with the tables please")
end

bot.message(starting_with: "#{$info["prefix"]}throw") do |event|
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
  event.respond("_throws a #{items.sample} at #{event.message.mentions[0].mention}_")
end

bot.message(starting_with: "#{$info["prefix"]}cuddle") do |event|
  event.respond("_picks up saiky and sets them in #{event.message.author.mention}'s lap_")
end

bot.message(containing: ["┬─┬﻿ ノ( ゜-゜ノ)","┬─┬ノ( º _ ºノ)", "┬───────────────┬﻿ ノ( ゜- ゜ノ)", "┬─────────────┬ ノ(^-^ノ)"]) do |event|
  event.respond(" (ﾉಥ益ಥ）ﾉ﻿ ┻━━━━━━━━━━━━━━┻ ")
end

bot.private_message() do |event|
  help(event)
end

bot.message() do |event|
  catchallevent(event,bot)
end


#bot.message(starting_with: "#{$info["prefix"]}watchthread") do |event|
  #watchthread(event, event.author)
#end

bot.run