#require 'rapngasm'
require 'fileutils'
require_relative 'frame_list.rb'
require_relative 'frame.rb'
require_relative 'rapngasm.bundle'

class APNGAsmGUI::Adapter
  def initialize
    @apngasm = APNGAsm.new
  end

  def import(frame_list, filename)
    apngframes = @apngasm.disassemble(filename)
    filename = set_filename(filename)
    new_frames = []
    apngframes.each_with_index do |apngframe, i|
      new_frames << APNGAsmGUI::Frame.new("#{filename}_#{i}.png", frame_list, apngframe)
    end
    new_frames
  end

  def export(frame_list, filename, frames_status)
    filename = set_filename(filename)

    frame_list.list.each do |frame|
      @apngasm.add_frame(set_apngframe(frame))
    end
    @apngasm.assemble("#{filename}.png")

    if frames_status
      save_frames(filename)
    end
  end

  def save_frames(filename)
    @apngasm.reset
    @apngasm.disassemble("#{filename}.png")
    FileUtils.mkdir_p(filename) unless File.exist?(filename)
    @apngasm.save_pngs(filename)
    @apngasm.save_json("#{filename}/animation.json", filename)
  end

  def set_apngframe(frame)
    # TODO  二度アセンブルすると画像にゴミが入るので確認
    frame.apngframe.delay_numerator(frame.delay)
    frame.apngframe
    # new_frame = APNGFrame.new(frame.filename)
    # new_frame.delay_numerator(frame.delay)
    # new_frame
  end

  def set_filename(filename)
    dirname = File.dirname(filename)
    basename = File.basename(filename, '.png')
    new_filename = "#{dirname}/#{basename}"
  end
end