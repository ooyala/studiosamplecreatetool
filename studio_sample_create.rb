require 'crack'
require 'json'
require 'dir'
require 'fileutils'

class StudioSampleCreate
  def initialize

  end

  def get_media_info(filepath)
    cmd = "mediainfo --Output=XML #{filepath}"
    mediainfo_xml = %x[#{cmd}]
    mediainfo_json = Crack::XML.parse(mediainfo_xml)
    puts "<<<<<<<<<<<<<<<<<<< Mediainfo [ #{filepath} ] >>>>>>>>>>>>>>>>>>>>>>>>"
    puts JSON.pretty_generate(mediainfo_json)
    puts "<<<<<<<<<<<<<<<<<<< Mediainfo [ #{filepath} ] >>>>>>>>>>>>>>>>>>>>>>>>\n\n"
  end

  def create_sample_studio_files(config)
    puts "********************************************"
    puts "#{JSON.pretty_generate(config)}"
    puts "********************END*********************\n\n"

    filesconfig = config["studiosamplegrammar"]
    if !filesconfig.nil? && !filesconfig.empty?
      filesconfig.each do |fileconfig|
        puts "*********************Processing [#{fileconfig["filename"]} ]*******************"
        create_sample_studio_file(fileconfig)
        puts "**********************Processed [#{fileconfig["filename"]} ]*******************\n\n"
      end
    end
  end

  def create_sample_studio_file(fileconfig)
    filename = fileconfig["filename"]
    puts "Creating a Directory #{filename}"
    if !Dir.exist?("#{filename}")
      res = Dir.mkdir(filename)
    else
      delete_all_files(filename)
      res = Dir.rmdir(filename)
      Dir.mkdir(filename)
    end
    create_tracks(fileconfig["tracks"], filename)
    process_tracks(fileconfig["tracks"], filename, fileconfig)
  end

  def delete_all_files(path)
    Dir.foreach(path) do |file|
      FileUtils.rm_f("#{path}/#{file}")
    end
  end

  def create_tracks(trackinfo, dirinfo)
    puts "track info #{trackinfo}"
    cmd = "ffmpeg -i source/mymovie_noaudio.mp4 "
    inputfiles = ''
    mapinfo = ''
    vacopy = "-c:v copy -c:a copy -map 0:v:0 "
    #vacopy = "-vcodec prores -profile:v 0 -vtag apcn -f mov -y -c:a pcm_s24le "
    index = 1
    opfile = "#{dirinfo}/#{dirinfo}.mp4"
    trackinfo.each do |track|
      inputfiles << "-i  source/myaudio.mov "
      mapinfo << "-map #{index}:a:0 "
      index = index +1
    end
    puts "#{cmd}#{inputfiles}#{vacopy}#{mapinfo}#{opfile}"
    cmd = "#{cmd}#{inputfiles}#{vacopy}#{mapinfo}#{opfile}"
    res = %x[#{cmd}]
    #puts res
  end

  def process_tracks(trackinfo, fileinfo, fileconfig)

    cmd ="ffmpeg -i #{fileinfo}/#{fileinfo}.mp4 "
    filtercomplex = "-filter_complex "
    pancmd = "[0:1]pan="
    paninfo = ''
    a_codec = "pcm_s24le "
    unless fileconfig["audio_code"].nil?
      a_codec = "#{fileconfig["audio_code"]} "
    end
    addparams = "-vcodec prores -profile:v 0 -vtag apcn -f mov -y -c:a #{a_codec} "
    #addparams = " -vcodec mpeg4 -acodec pcm_s24le -y "
    mapinfo = '-map v:0 '
    index = 0
    langinfo = ''
    opfile = "#{fileinfo}/#{fileinfo}.mov"
    trackinfo.each do |track|
      ch_layout = track["ch_layout"]
      lang = track["language"]
      if track ==trackinfo.last
        paninfo << "#{pancmd}#{ch_layout}|c0=c#{index}[#{ch_layout}]"
      else
        paninfo << "#{pancmd}#{ch_layout}|c0=c#{index}[#{ch_layout}];"
      end
      mapinfo << "-map \"[#{ch_layout}]\" "
      langinfo << "-metadata:s:a:#{index} language=#{lang} "
      index = index +1
    end
    puts "#{cmd}#{filtercomplex}\"#{paninfo}\" #{mapinfo}#{langinfo}#{addparams}#{opfile}"
    cmd = "#{cmd}#{filtercomplex}\"#{paninfo}\" #{mapinfo}#{langinfo}#{addparams}#{opfile}"
    res = %x[#{cmd}]
    get_media_info("#{fileinfo}/#{fileinfo}.mov")
  end

end

ssc = StudioSampleCreate.new
#ssc.get_media_info("source/mymovie.mov")
config = File.read("config/studiosample.json")
studio_config = JSON.parse(config)
ssc.create_sample_studio_files(studio_config)