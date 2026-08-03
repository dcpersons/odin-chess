class Pieces
  TYPE = 'no type'
  def type
    self.class::TYPE
  end
end

Dir.glob('lib/pieces/**.rb') { |name| require_relative "../#{name}" }
