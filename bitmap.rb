class BitMap
  class Writer
    PIXEL_OFFSET = 54
    BITS_PER = 24
    PIXELS_PER_METER   = 2835 # 2835 pixels per meter is basically 72dpi

    def initialize(w,h)
      @w, @h = w,h
      @pixels = Array.new(@h) {Array.new(@w) {"000000"}}
    end

    def []=(x,y,val)
      @pixels[y][x] = val
    end

    def save_as(filename)
      FIle.open(filename, "wb") do |f|
        write_bm_header(f)
        write_dib_header(f)
        write_pixels(f)
      end
    end

    def write_bm_header(file)
      file << ["BM", file_size, 0,0,PIXEL_OFFSET].pack("A2Vv2V")
    end

    def file_size
      PIXEL_OFFSET + pixel_array_size
    end

    def pixel_array_size
      ((BITS_PER*@w)/32.0).ceil*4*@h
    end

    def write_dib_header(file)
      file << [DIB_HEAD_SIZE, @w, @h, 1, 
              BITS_PER, 0, pixel_array_size, 
              PIXELS_PER_METER, PIXELS_PER_METER, 0, 0,].pack("Vl<2v2V2l<2V2")
    end

    def write_pixels(file)
      @pixels.reverse_each do |row|
        row.each do |color|
          file << pixel_binstring(color)
        end
        file << row_pad
      end
    end

    def pixel_binstring(rgb_string)
      raise ArgumentError unless rgb_string =~ /\A\h{6}\z/
      [rgb_string].pack("H6")
    end

    def row_pad
      "\x0" * (@w % 4)
    end
  end
end