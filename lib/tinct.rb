class Tinct
  VERSION = '0.0.2'.freeze

  attr_accessor :red, :green, :blue, :alpha

  def initialize(red = 0, green = 0, blue = 0, alpha = 1)
    @red = red.to_f.clamp(0.0, 1.0)
    @green = green.to_f.clamp(0.0, 1.0)
    @blue = blue.to_f.clamp(0.0, 1.0)
    @alpha = alpha.to_f.clamp(0.0, 1.0)
  end

  def hue
    max = [@red, @green, @blue].max
    min = [@red, @green, @blue].min
    delta = max - min
    return 0 if delta == 0
    return (((@green - @blue) / delta) % 6) / 6 if max == @red
    return (((@blue - @red) / delta) + 2) / 6 if max == @green
    return (((@red - @green) / delta) + 4) / 6
  end

  def hue=(hue)
    copy(Tinct.hsl(hue, saturation, lightness, alpha))
    hue
  end

  def saturation
    max = [@red, @green, @blue].max
    min = [@red, @green, @blue].min
    delta = max - min
    total = max + min
    l = total / 2
    return 0 if delta == 0
    l < 0.5 ? delta / total : delta / (2 - max - min)
  end

  def saturation=(saturation)
    copy(Tinct.hsl(hue, saturation, lightness, alpha))
    saturation
  end

  def lightness
    max = [@red, @green, @blue].max
    min = [@red, @green, @blue].min
    (max + min) / 2
  end

  def lightness=(lightness)
    copy(Tinct.hsl(hue, saturation, lightness, alpha))
    lightness
  end

  def value
    [@red, @green, @blue].max
  end

  def value=(value)
    copy(Tinct.hsv(hue, saturation, value, alpha))
    value
  end

  def brightness
    value
  end

  def brightness=(brightness)
    self.value = brightness
  end

  def cyan
    k = key
    (1 - @red - k) / (1 - k)
  end

  def cyan=(cyan)
    cyan = cyan.to_f.clamp(0.0, 1.0)
    self.red = (1 - cyan) * (1 - key)
    cyan
  end

  def magenta
    k = key
    (1 - @green - k) / (1 - k)
  end

  def magenta=(magenta)
    magenta = magenta.to_f.clamp(0.0, 1.0)
    self.green = (1 - magenta) * (1 - key)
    magenta
  end

  def yellow
    k = key
    (1 - @blue - k) / (1 - k)
  end

  def yellow=(yellow)
    yellow = yellow.to_f.clamp(0.0, 1.0)
    self.blue = (1 - yellow) * (1 - key)
    yellow
  end

  def key
    1 - [@red, @green, @blue].max
  end

  def key=(key)
    key = key.to_f.clamp(0.0, 1.0)
    self.red = (1 - cyan) * (1 - key)
    self.green = (1 - magenta) * (1 - key)
    self.blue = (1 - yellow) * (1 - key)
    key
  end

  def self.hsl(hue = 0, saturation = 0, lightness = 0, alpha = 255)
    hue = hue.to_f.clamp(0.0, 1.0) * 360
    saturation = saturation.to_f.clamp(0.0, 1.0)
    lightness = lightness.to_f.clamp(0.0, 1.0)
    alpha = alpha.to_f.clamp(0.0, 1.0)
    c = (1 - (2 * lightness - 1).abs) * saturation
    x = c * (1 - ((hue / 60) % 2 - 1).abs)
    m = lightness - c / 2
    cxm(hue, c, x, m, alpha)
  end

  def self.hsv(hue = 0, saturation = 0, value = 1, alpha = 1)
    hue = hue.to_f.clamp(0.0, 1.0) * 360
    saturation = saturation.to_f.clamp(0.0, 1.0)
    value = value.to_f.clamp(0.0, 1.0)
    alpha = alpha.to_f.clamp(0.0, 1.0)
    c = value * saturation
    x = c * (1 - ((hue / 60) % 2 - 1).abs)
    m = value - c
    cxm(hue, c, x, m, alpha)
  end

  def self.hsb(hue = 0, saturation = 0, brightness = 1, alpha = 1)
    self.hsv(hue, saturation, brightness, alpha)
  end

  def self.cxm(hue, c, x, m, alpha)
    r_prime, g_prime, b_prime = 0, 0, 0
    if hue < 60
      r_prime, g_prime = c, x
    elsif hue < 120
      r_prime, g_prime = x, c
    elsif hue < 180
      g_prime, b_prime = c, x
    elsif hue < 240
      g_prime, b_prime = x, c
    elsif hue < 300
      r_prime, b_prime = x, c
    else
      r_prime, b_prime = c, x
    end
    Tinct.new(r_prime + m, g_prime + m, b_prime + m, alpha)
  end

  private_class_method :cxm

  def self.rgb(red = 0, green = 0, blue = 0, alpha = 1)
    Tinct.new(red, green, blue, alpha)
  end

  def self.cmyk(cyan = 0, magenta = 0, yellow = 0, key = 0, alpha = 1)
    cyan = cyan.to_f.clamp(0.0, 1.0)
    magenta = magenta.to_f.clamp(0.0, 1.0)
    yellow = yellow.to_f.clamp(0.0, 1.0)
    key = key.to_f.clamp(0.0, 1.0)
    alpha = alpha.to_f.clamp(0.0, 1.0)
    Tinct.new(
      (1 - cyan) * (1 - key),
      (1 - magenta) * (1 - key),
      (1 - yellow) * (1 - key),
      alpha
    )
  end

  def self.from_i(i, rgba = false)
    i = i.to_i
    alpha = 0
    if rgba
      alpha = i % 256 / 255.0
      i /= 256
    end
    blue = i % 256 / 255.0
    i /= 256
    green = i % 256 / 255.0
    i /= 256
    red = i % 256 / 255.0
    i /= 256
    alpha = i unless rgba
    Tinct.new(red, green, blue, alpha)
  end

  def self.from_s(s)
    s = s.rjust(6, '0')
    s = 'ff' + s if s.length == 6
    self.from_i(s.to_s.to_i(16))
  end

  def to_i(rgba = false)
    i = 0
    i = @alpha * 255 unless rgba
    i *= 256
    i += @red * 255
    i *= 256
    i += @green * 255
    i *= 256
    i += @blue * 255
    if rgba
      i *= 256
      i += @alpha * 255
    end
    i.to_i
  end

  def to_s(include_alpha = false)
    s = to_i.to_s(16).rjust(8, '0')
    s = s[2..-1] unless include_alpha
    s
  end

  def self.mix(a, b)
    a.mix(b)
  end

  def mix(other)
    dup.mix!(other)
  end

  def mix!(other)
    self.red = (@red + other.red) / 2
    self.green = (@green + other.green) / 2
    self.blue = (@blue + other.blue) / 2
    self.alpha = (@alpha + other.alpha) / 2
    self
  end

  def lighten(percentage)
    dup.lighten!(percentage)
  end

  def lighten!(percentage)
    percentage = percentage.to_f.clamp(0.0, 1.0)
    self.key = key + percentage * (1 - key)
    self
  end

  def darken(percentage)
    dup.darken!(percentage)
  end

  def darken!(percentage)
    percentage = percentage.to_f.clamp(0.0, 1.0)
    self.key = percentage * key
    self
  end

  private

  def copy(other)
    self.red = other.red
    self.green = other.green
    self.blue = other.blue
    self.alpha = other.alpha
  end
end