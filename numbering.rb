
# Track numbering of sections or bulleted lists, up to 4 levels
class Numbering
  def initialize
    @l1 = @l2 = @l3 = @l4 = 0
  end

  # Get next level 1 number
  def h1
    @l1 += 1
    @l2 = @l3 = @l4 = 0
    "#{@l1}"
  end

  # Get next level 2 number
  def h2
    @l2 += 1
    @l3 = @l4 = 0
    "#{@l1}.#{@l2}"
  end

  # Get next level 3 number
  def h3
    @l3 += 1
    @l4 = 0
    "#{@l1}.#{@l2}.#{@l3}"
  end

  # Get next level 4 number
  def h4
    @l4 += 1
    "#{@l1}.#{@l2}.#{@l3}.#{@l4}"
  end
end

