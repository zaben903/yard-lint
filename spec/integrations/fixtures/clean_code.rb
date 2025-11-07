# frozen_string_literal: true

# Properly documented class
class CleanCode
  # Initialize the clean code instance
  # @param name [String] the name
  # @param value [Integer] the value
  def initialize(name, value)
    @name = name
    @value = value
  end

  # Calculate result
  # @param multiplier [Integer] multiplication factor
  # @return [Integer] calculated result
  def calculate(multiplier)
    @value * multiplier
  end

  # Check if active
  # @return [Boolean] whether active
  def active?
    @value.positive?
  end
end
