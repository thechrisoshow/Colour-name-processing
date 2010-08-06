

require 'rubygems'


require 'matrix'

module ColourGrabber
  COLOURS = {
    # 
    # 235..255 => "Red",
    # 0..20 => "Red",
    # 21..60 => "Yellow",
    # 61..100 => "Green",
    # 101..140 => "Cyan",
    # 141..180 => "Blue",
    # 181..234 => "Magenta"
    
    
    
   0..80 => "Orange",
   81..89 => "Yellow",
   90..108 => "Pink",
   109..129 => "Green",
   130..200 => "Blue",
   201..220 => "Red",
   221..360 => "Yellow"
    
    # Vector[0,0,100] => "Red",
    # Vector[56,0,100] => "Yellow",
    # Vector[305,0,100] => "Pink",
    # Vector[127,0,100] => "Green",
    # Vector[282,0,100] => "Purple",
    # Vector[25, 0, 100] => "Orange",
    # Vector[245,0,100] => "Blue",
    # Vector[0,0,0] => "White",
    # Vector[0,100,0] => "Black",
  }

  class << self
    
    def get_colour_name(h, s, br)
      h = ((h / 255.0 * 360).to_i + 70) % 360      
      if br < 10
        return "Black"
      elsif s < 90 && br > 70
        return "White"
      # elsif s > 50 && br > 70 && (47..120).include?(h)
      #   return "Beige"
      else
        key = COLOURS.keys.select {|range| range.include?(h) }.first
        # key = COLOURS.keys.sort_by {|c| ((h / 360.0) * 255 - c).abs % 255 }.first
        return COLOURS[key]

      end
      
    end
    
    
    # def get_colour_name(r,g,b)
    #   v = Vector[r,g,b]
    #   key = COLOURS.keys.sort_by {|c| c.distance_to(v)}.first
    #   return COLOURS[key]
    # end
  end
end

class Vector
  def distance_to(other)
    (self - other).map {|n| n.abs }.r
  end
end

require "json"
require 'net/http'

class ColoursSketch < Processing::App

  load_library :video

  # We need the video classes to be included here.
  include_package "processing.video"

  attr_accessor :capture, :sample_rate

  def setup    
    frame_rate 10
    smooth
    size(1024, 768)

    # set colour to RGBA.
    colorMode(RGB, 100);

    # text_font load_font("Univers66.vlw.gz")
    
    courier = create_font("Monaco", 32);
    text_font(courier);

    # You can get a list of cameras
    # by doing Capture.list
    # 
    # cameras = Capture.list.to_a
    # puts cameras
    # @capture = Capture.new(self, width, height, cameras[1], 30)
    # 
    # or you can use your default
    # webcam by leaving it out of
    # the parameters ..
    #  
    @capture = Capture.new(self, width, height, 30)
    @sample_rate = 10
  end

  def draw    
    capture.read if capture.available
    convert_pixels
  end

  def clear
    background 0
  end

  def convert_pixels
    clear

    tweet_char = 0


    pixels_to_skip = 0

    (1...height).step(sample_rate) do |y|
      (1...width).step(sample_rate) do |x|          
        pixel = y * capture.width + x

        r = red(capture.pixels[pixel])
        g = green(capture.pixels[pixel])
        b = blue(capture.pixels[pixel])

        c = color(r,g,b,100)        
        h = hue(c)
        s = saturation(c)  
        br = brightness(c)  
        

        base_size = map(red(capture.pixels[pixel]), 0, 255, 0, 50)

        size = map(red(capture.pixels[pixel]), 0, 255, 0, base_size)

        fill(c)

        if pixels_to_skip > 0
          pixels_to_skip = pixels_to_skip - 1
        else
          size = sample_rate

          textSize(size)


          colour_name = ColourGrabber.get_colour_name(h, s , br)
          text(colour_name, x, y)
          pixels_to_skip = colour_name.size / 2
        end

      end
    end    
  end

end

@art = ColoursSketch.new :title => "Colours baby"