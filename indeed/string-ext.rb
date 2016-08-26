# May not be in use

class String

  # levenshtein_distance
  def ld str
    s = self
    t = str
    n = s.length
    m = t.length

    return m if (0 == n)
    return n if (0 == m)

    d = (0..m).to_a
    x = nil

    s.each_char.each_with_index do |char1,i|
      e = i+1

      t.each_char.each_with_index do |char2,j|
        cost = (char1 == char2) ? 0 : 1
        x = min3(
             d[j+1] + 1, # insertion
             e + 1,      # deletion
             d[j] + cost # substitution
            )
        d[j] = e
        e = x
      end

      d[m] = x
    end

    return x
  end


  def min3 a, b, c # :nodoc:
    if a < b && a < c then
      a
    elsif b < c then
      b
    else
      c
    end
  end

end
