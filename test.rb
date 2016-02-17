require "youtube-dl"
options = {
  extract_audio: true,
  audio_format: 'mp3',
  output: "%(title)s.mp3"
}

puts (YoutubeDL.download "https://www.youtube.com/watch?v=gvdf5n-zI14", options).filename
