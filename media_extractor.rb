
class MediaExtractor
  def initialize
  end
  def extract_audio_file(source)
  	cmd = "ffmpeg -i  #{source} -vn -acodec copy source/myaudio.mov"
  	res = %x[#{cmd}]
  	puts res
  end

  def remove_audio_from_source(source)
  	cmd = "ffmpeg -i #{source} -c copy -an source/mymovie_noaudio.mp4"
  	res = %x[#{cmd}]
  	puts res
  end

end

unless ARGV[0].nil?
	puts "#{ARGV[0]}"
	if File.exist?(ARGV[0])
		me = MediaExtractor.new
		me.extract_audio_file(ARGV[0])
		me.remove_audio_from_source(ARGV[0])
	else	
		puts "supplied source does not exist"
	end
else
	puts "ERROR::Please provide one Media file as an input"
end
