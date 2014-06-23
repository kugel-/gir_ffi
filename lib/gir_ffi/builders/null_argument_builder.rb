module GirFFI
  # Argument builder that does nothing. Implements the Null Object pattern.
  class NullArgumentBuilder
    def initialize *; end

    def pre_conversion; []; end

    def post; []; end

    def callarg; end
  end
end
