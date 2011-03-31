module Stupidedi
  module Dictionaries
    module FunctionalGroups
      module FiftyTen
        module ElementTypes

          #
          # @see X222.pdf B.1.1.3.1.1 Numeric
          #
          class NumericVal < Values::SimpleElementVal

            #
            #
            #
            class Invalid < NumericVal

              # @return [Object]
              attr_reader :value

              def initialize(value, usage)
                super(usage)
                @value = value
              end

              def valid?
                false
              end

              def empty?
                false
              end

              # @return [String]
              def inspect
                id = definition.bind do |d|
                  "[#{'% 5s' % d.id}: #{d.name}]".bind do |s|
                    if usage.forbidden?
                      ansi.forbidden(s)
                    elsif usage.required?
                      ansi.required(s)
                    else
                      ansi.optional(s)
                    end
                  end
                end

                ansi.element("Nn.invalid#{id}") << "(#{ansi.invalid(@value.inspect)})"
              end

              # @return [Boolean]
              def ==(other)
                eql?(other) or
                  (other.is_a?(Invalid) and @value == other.value)
              end
            end

            #
            # Empty numeric value. Shouldn't be directly instantiated -- instead
            # use the {NumericVal.value} and {NumericVal.empty} constructors.
            #
            class Empty < NumericVal

              def valid?
                true
              end

              def empty?
                true
              end

              # @return [String]
              def inspect
                id = definition.bind do |d|
                  "[#{'% 5s' % d.id}: #{d.name}]".bind do |s|
                    if usage.forbidden?
                      ansi.forbidden(s)
                    elsif usage.required?
                      ansi.required(s)
                    else
                      ansi.optional(s)
                    end
                  end
                end

                ansi.element("Nn.empty#{id}")
              end

              def to_s
                ""
              end

              # @return [Boolean]
              def ==(other)
                other.is_a?(Empty)
              end
            end

            #
            # Non-empty numeric value. Shouldn't be directly instantiated --
            # instead, use the {NumericVal.value} constructors.
            #
            class NonEmpty < NumericVal
              include Comparable

              # @return [BigDecimal]
              attr_reader :value

              delegate :to_i, :to_d, :to_f, :to_s, :to => :@value

              def initialize(value, usage)
                @value = value
                super(usage)
              end

              # @return [NonEmpty]
              def copy(changes = {})
                NonEmpty.new \
                  changes.fetch(:value, @value),
                  changes.fetch(:usage, usage)
              end

              def valid?
                true
              end

              def empty?
                false
              end

              # @return [Array(NonEmpty, Numeric)]
              def coerce(other)
                if other.respond_to?(:to_d)
                  # Re-evaluate other.call(self) as self.op(other.to_d)
                  return self, other.to_d
                else
                  # Fail, other.call(self) is still other.call(self)
                  raise TypeError, "#{other.class} can't be coerced into NumericVal"
                end
              end

              # @return [String]
              def inspect
                id = definition.bind do |d|
                  "[#{'% 5s' % d.id}: #{d.name}]".bind do |s|
                    if usage.forbidden?
                      ansi.forbidden(s)
                    elsif usage.required?
                      ansi.required(s)
                    else
                      ansi.optional(s)
                    end
                  end
                end

                ansi.element("Nn.value#{id}") << "(#{@value.to_s('F')})"
              end

              # @group Mathematical Operators
              #################################################################

              # @return [NonEmpty]
              def /(other)
                copy(:value => (@value / other).to_d)
              end

              # @return [NonEmpty]
              def +(other)
                copy(:value => (@value + other).to_d)
              end

              # @return [NonEmpty]
              def -(other)
                copy(:value => (@value - other).to_d)
              end

              # @return [NonEmpty]
              def **(other)
                copy(:value => (@value ** other).to_d)
              end

              # @return [NonEmpty]
              def *(other)
                copy(:value => (@value * other).to_d)
              end

              # @return [NonEmpty]
              def %(other)
                copy(:value => (@value % other).to_d)
              end

              # @return [NonEmpty]
              def -@
                copy(:value => -@value)
              end

              # @return [NonEmpty]
              def +@
                self
              end

              # @return [NonEmpty]
              def abs
                copy(:value => @value.abs)
              end

              # @return [-1, 0, +1]
              def <=>(other)
                if other.respond_to?(:value)
                  @value <=> other.value
                else
                  @value <=> other
                end
              end

              # @endgroup
              #################################################################
            end

          end

          class << NumericVal
            # @group Constructors
            ###################################################################

            # @return [NumericVal]
            def empty(usage)
              NumericVal::Empty.new(usage)
            end

            # @return [NumericVal]
            def value(object, usage)
              if object.blank?
                NumericVal::Empty.new(usage)
              elsif object.respond_to?(:to_d)
                NumericVal::NonEmpty.new(object.to_d, usage)
              else
                NumericVal::Invalid.new(string, usage)
              end
            rescue ArgumentError
              NumericVal::Invalid.new(string, usage)
            end

            # @return [NumericVal]
            def value(string, usage)
              if string.blank?
                NumericVal::Empty.new(usage)
              else
                NumericVal::NonEmpty.new(string.to_d, usage)
              end
            rescue ArgumentError
              NumericVal::Invalid.new(string, usage)
            end

            # @endgroup
            ###################################################################
          end

          # Prevent direct instantiation of abstract class NumericVal
          NumericVal.eigenclass.send(:protected, :new)
          NumericVal::Empty.eigenclass.send(:public, :new)
          NumericVal::Invalid.eigenclass.send(:public, :new)
          NumericVal::NonEmpty.eigenclass.send(:public, :new)
        end

      end
    end
  end
end
