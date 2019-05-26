class Integer
  def to_tinct(rgba = false)
    Tinct.from_i(self, rgba)
  end
end
