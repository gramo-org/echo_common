require 'echo_common/error'

module EchoCommon
  module StateMachine
    #
    # Contains functionality for a simple state machine
    #
    # You get two methods related to each event:
    #   - `can_<event>?   Checks if you can transition via event
    #   - `<event>!`      Transitions state via event, or fails with StateTransitionError
    #
    # Example of usage, after included in a class:
    #
    # event :run, from: ["standing", "walking"], to: "running"
    # event :fly, from: "running", to: "flying", guard: -> { superman? }
    #
    # object = SomeStateMachine.new
    # object.can_run?
    # object.run!
    #
    module Machine
        class StateTransitionError < EchoCommon::Error; end

        def self.included(base)
          base.class_eval do
            def self.known_states
              @@known_states ||= []
            end
            def self.known_states=(states)
              @@known_states ||= states
            end

            extend ClassMethods
          end
        end

        module ClassMethods
          def event(name, from:, to:, guard: nil)
            transition_to_state   = to.to_s
            transition_from_states = Array(from).map(&:to_s)

            self.known_states |= transition_from_states.dup.push(transition_to_state)

            define_event_can_method_for name, from: transition_from_states, to: transition_to_state, guard: guard
            define_event_method_for     name, to: transition_to_state
            define_state_predicate_for  transition_from_states | [transition_to_state]
          end

          private


          def define_event_can_method_for(event_name, from:, to:, guard:)
            define_method("can_#{event_name}?") do |raise_error: false|
              # Check from -> to state
              err = unless from.include?(state)
                "Cannot transition from state #{state} to #{to}. Valid states for this transition is #{from.join(", ")}."
              end

              # Check guard
              if err.nil?
                passed_guard = case guard
                when Symbol, String
                  public_send(guard)
                when Proc
                  if guard.arity.zero?
                    instance_exec &guard
                  else
                    guard.call self
                  end
                when nil
                  true
                else
                  fail ArgumentError,
                    "Guard may be method name (symbol or string), or a lambda / proc. Was: #{guard.inspect}"
                end

                unless passed_guard
                  err = "Cannot transition from state #{state} to #{to}. Prohibited by guard."
                end
              end


              if err.nil?
                true
              else
                if raise_error
                  fail StateTransitionError, err
                else
                  false
                end
              end
            end
          end

          def define_event_method_for(event_name, to:)
            define_method("#{event_name}!") do
              if public_send("can_#{event_name}?", raise_error: true)
                self.state = to
              end
            end
          end

          def define_state_predicate_for(state_names)
            state_names.each do |state_name|
              predicate = "#{state_name}?"
              next if respond_to? predicate
              
              define_method predicate do
                state == state_name
              end
            end
          end
        end



    end
  end
end
