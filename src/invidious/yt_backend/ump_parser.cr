struct UMPPart
  type : Int64
  size : Int64
  data : Bytes
end

class UMPParser
  property buffer : Bytes
  property offset : Int64

  def initialize(@buffer)
    @offset = 0
  end

  def read_varint
    prefix = @buffer[@offset]
    size = self.varint_size(prefix)
    result = 0
    shift = 0

    if size != 5
      shift = 8 - size
      mask = (1 << shift) - 1
      result |= prefix & mask
    end

    (1..size).each do |i|
      byte = @buffer[@offset + i]
      result |= byte << shift
      shift += 8
    end

    @offset += size
    return result
  end

  def varint_size(byte : UInt8)
    lo = 0

    [7, 6, 5, 4].each do |i|
      if byte & (1 << i)
        lo += 1
      else
        break
      end
    end

    return Math.min(lo + 1, 5)
  end

  def parse : Array(UMPPart)
    parts = [] of UMPPart

    while @offset < @buffer.length
      part_type = self.read_varint
      part_size = self.read_varint

      part_data = @buffer.slice(@offset, @offset + part_size)
      @offset += part_size

      parts << UMPPart{
        "type" => part_type,
        "size" => part_size,
        "data" => part_data,
      }
    end

    return parts
  end
end
